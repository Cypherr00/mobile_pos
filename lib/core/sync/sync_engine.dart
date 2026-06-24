// core/sync/sync_engine.dart
// Handles background offline-first replication logic

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import '../network/supabase_service.dart';
import '../database/app_database.dart';

class SyncEngine {
  SyncEngine._();
  static final SyncEngine instance = SyncEngine._();

  static const String _deviceIdPrefKey = 'pos_device_id';
  String? _deviceId;

  // Retrieve unique identifier for this physical terminal
  Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_deviceIdPrefKey);
    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString(_deviceIdPrefKey, id);
    }
    _deviceId = id;
    return id;
  }

  // Orchestrate sync process across all synchronized tables
  Future<void> syncAll() async {
    final supabase = SupabaseService.instance;
    if (!supabase.isInitialized) {
      throw Exception('Supabase connection not configured. Sync skipped.');
    }

    debugPrint('SyncEngine: Commencing synchronisation run...');
    try {
      await syncCashiers();
      await syncProducts();
      await syncTransactions();
      debugPrint('SyncEngine: Sync completed successfully.');
    } catch (e, stack) {
      debugPrint('SyncEngine: Error during sync processing: $e\n$stack');
      rethrow; // Ensure the UI catches this and shows the error!
    }
  }

  // Pull cashiers from Supabase and cache locally (Read-only on device)
  Future<void> syncCashiers() async {
    final client = SupabaseService.instance.client;
    final db = AppDatabase.instance.db;

    // Fetch active cashiers from the cloud
    final List<dynamic> data = await client
        .from('cashiers')
        .select()
        .eq('is_active', true);

    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      for (final item in data) {
        final id = item['id'] as String;
        final name = item['name'] as String;
        final email = item['email'] as String? ?? '';
        final pinHash = item['pin_hash'] as String;
        final role = item['role'] as String;
        final isActive = (item['is_active'] as bool) ? 1 : 0;
        final createdAt = item['created_at'] as String? ?? now;
        final updatedAt = item['updated_at'] as String? ?? now;

        await txn.insert(
          'cashiers',
          {
            'id': id,
            'name': name,
            'email': email,
            'pin_hash': pinHash,
            'role': role,
            'is_active': isActive,
            'created_at': createdAt,
            'updated_at': updatedAt,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
    debugPrint('SyncEngine: Synchronised ${data.length} cashiers to local SQLite cache.');
  }

  // Centralised catalog sync. Local product changes push up, cloud updates override local.
  Future<void> syncProducts() async {
    final client = SupabaseService.instance.client;
    final db = AppDatabase.instance.db;

    // 1. Push local changes (created/edited/soft-deleted)
    final unsynced = await db.query('products', where: 'is_synced = 0');
    if (unsynced.isNotEmpty) {
      for (final row in unsynced) {
        final id = row['id'] as String;
        final name = row['name'] as String;
        final priceCents = row['price_cents'] as int;
        final isDeleted = row['is_deleted'] == 1;
        final version = row['version'] as int;

        // Fetch cloud version to prevent overwriting a newer cloud version
        final cloudRes = await client.from('products').select('version').eq('id', id).maybeSingle();
        final cloudVersion = cloudRes != null ? (cloudRes['version'] as int? ?? 0) : 0;

        if (version >= cloudVersion) {
          await client.from('products').upsert({
            'id': id,
            'name': name,
            'price_cents': priceCents,
            'is_deleted': isDeleted,
            'version': version,
          });
        }
      }
      
      // Update local catalog sync flag
      await db.update('products', {'is_synced': 1}, where: 'is_synced = 0');
      debugPrint('SyncEngine: Pushed ${unsynced.length} unsynced product catalogue updates.');
    }

    // 2. Pull cloud changes to override local database catalog ONLY IF cloud version is newer
    final List<dynamic> cloudProducts = await client
        .from('products')
        .select();

    await db.transaction((txn) async {
      for (final item in cloudProducts) {
        final id = item['id'] as String;
        final name = item['name'] as String;
        final priceCents = item['price_cents'] as int;
        final isDeleted = (item['is_deleted'] as bool) ? 1 : 0;
        final createdAt = item['created_at'] as String? ?? DateTime.now().toIso8601String();
        final version = item['version'] as int? ?? 1;

        // Check local version
        final localRes = await txn.query('products', columns: ['version'], where: 'id = ?', whereArgs: [id]);
        final localVersion = localRes.isNotEmpty ? (localRes.first['version'] as int) : 0;

        if (version > localVersion) {
          await txn.insert(
            'products',
            {
              'id': id,
              'name': name,
              'price_cents': priceCents,
              'is_deleted': isDeleted,
              'created_at': createdAt,
              'version': version,
              'is_synced': 1,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
    debugPrint('SyncEngine: Pulled ${cloudProducts.length} products from cloud and applied updates.');
  }

  // Push local transactions up to Supabase. Transactions are append-only.
  Future<void> syncTransactions() async {
    final client = SupabaseService.instance.client;
    final db = AppDatabase.instance.db;
    final devId = await getDeviceId();

    // Query unsynced transaction headers
    final unsyncedTxns = await db.query('transactions', where: 'is_synced = 0');
    if (unsyncedTxns.isEmpty) return;

    for (final txnRow in unsyncedTxns) {
      final txnId = txnRow['id'] as String;
      final totalAmountCents = txnRow['total_amount_cents'] as int;
      final totalItems = txnRow['total_items'] as int;
      final createdAt = txnRow['created_at'] as String;
      final cashierId = txnRow['cashier_id'] as String?;

      // Query line items belonging to this transaction
      final itemRows = await db.query(
        'transaction_items',
        where: 'transaction_id = ?',
        whereArgs: [txnId],
      );

      // Upload transaction header
      await client.from('transactions').insert({
        'id': txnId,
        'total_amount_cents': totalAmountCents,
        'total_items': totalItems,
        'device_id': devId,
        'cashier_id': cashierId,
        'created_at': createdAt,
      });

      // Upload line items payload
      final List<Map<String, dynamic>> itemsPayload = itemRows.map((itemRow) {
        return {
          'id': itemRow['id'] as String,
          'transaction_id': txnId,
          'product_id': itemRow['product_id'] as String,
          'product_name': itemRow['product_name'] as String,
          'price_cents': itemRow['price_cents'] as int,
          'quantity': itemRow['quantity'] as int,
          'created_at': createdAt,
        };
      }).toList();

      if (itemsPayload.isNotEmpty) {
        await client.from('transaction_items').insert(itemsPayload);
      }

      // Mark transaction header as synced
      await db.update(
        'transactions',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [txnId],
      );
    }
    debugPrint('SyncEngine: Synchronised ${unsyncedTxns.length} sales transactions to Supabase.');
  }
}
