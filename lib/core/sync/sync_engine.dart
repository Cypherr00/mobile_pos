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

  // Synchronize cashiers bidirectionally
  Future<void> syncCashiers() async {
    final client = SupabaseService.instance.client;
    final db = AppDatabase.instance.db;

    // 1. Push local changes
    final unsynced = await db.query('cashiers', where: 'is_synced = 0');
    if (unsynced.isNotEmpty) {
      final List<String> pushedIds = [];
      for (final row in unsynced) {
        await client.from('cashiers').upsert({
          'id': row['id'],
          'name': row['name'],
          'pin_hash': row['pin_hash'],
          'role': row['role'],
          'is_active': row['is_active'] == 1,
          'created_at': row['created_at'],
          'updated_at': row['updated_at'],
        });
        pushedIds.add(row['id'] as String);
      }
      if (pushedIds.isNotEmpty) {
        final placeholders = pushedIds.map((_) => '?').join(',');
        await db.update('cashiers', {'is_synced': 1}, where: 'is_synced = 0 AND id IN ($placeholders)', whereArgs: pushedIds);
      }
      debugPrint('SyncEngine: Pushed ${unsynced.length} cashier updates.');
    }

    // 2. Pull all cashiers from the cloud
    final List<dynamic> data = await client.from('cashiers').select();

    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      for (final item in data) {
        final id = item['id'] as String;
        final name = item['name'] as String;
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
            'pin_hash': pinHash,
            'role': role,
            'is_active': isActive,
            'created_at': createdAt,
            'updated_at': updatedAt,
            'is_synced': 1,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
    debugPrint('SyncEngine: Pulled ${data.length} cashiers from local SQLite cache.');
  }

  // Centralised catalog sync. Local product changes push up, cloud updates override local.
  Future<void> syncProducts() async {
    final client = SupabaseService.instance.client;
    final db = AppDatabase.instance.db;

    // 1. Push local changes (created/edited/soft-deleted)
    final unsynced = await db.query('products', where: 'is_synced = 0');
    if (unsynced.isNotEmpty) {
      final List<String> pushedIds = [];
      for (final row in unsynced) {
        final id = row['id'] as String;
        final name = row['name'] as String;
        final priceCents = row['price_cents'] as int;
        final isDeleted = row['is_deleted'] == 1;
        final version = row['version'] as int;

        // Fetch cloud version to prevent overwriting a newer cloud version
        final cloudRes = await client.from('products').select('version').eq('id', id).maybeSingle();
        final cloudVersion = cloudRes != null ? ((cloudRes['version'] as num?)?.toInt() ?? 0) : 0;

        if (version >= cloudVersion) {
          await client.from('products').upsert({
            'id': id,
            'name': name,
            'price_cents': priceCents,
            'is_deleted': isDeleted,
            'version': version,
          });
        }
        pushedIds.add(id);
      }
      
      // Update local catalog sync flag
      if (pushedIds.isNotEmpty) {
        final placeholders = pushedIds.map((_) => '?').join(',');
        await db.update('products', {'is_synced': 1}, where: 'is_synced = 0 AND id IN ($placeholders)', whereArgs: pushedIds);
      }
      debugPrint('SyncEngine: Pushed ${unsynced.length} unsynced product catalogue updates.');
    }

    // 2. Pull cloud changes to override local database catalog.
    // This ensures that any direct edits to the online database are absorbed offline.
    final List<dynamic> cloudProducts = await client
        .from('products')
        .select();

    final locallyUnsynced = await db.query('products', columns: ['id'], where: 'is_synced = 0');
    final locallyUnsyncedIds = locallyUnsynced.map((e) => e['id']).toSet();

    await db.transaction((txn) async {
      for (final item in cloudProducts) {
        final id = item['id'] as String;
        if (locallyUnsyncedIds.contains(id)) continue; // Prevent overwriting local offline edits
        
        final name = item['name'] as String;
        final priceCents = (item['price_cents'] as num).toInt();
        final isDeleted = (item['is_deleted'] as bool) ? 1 : 0;
        final createdAt = item['created_at'] as String? ?? DateTime.now().toIso8601String();
        final version = (item['version'] as num?)?.toInt() ?? 1;

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
          conflictAlgorithm: ConflictAlgorithm.replace, // Overwrite local with cloud to guarantee accuracy
        );
      }
    });
    debugPrint('SyncEngine: Pulled ${cloudProducts.length} products from cloud and applied updates.');
  }

  // Push local transactions up to Supabase. Transactions are append-only locally but can be edited online.
  Future<void> syncTransactions() async {
    final client = SupabaseService.instance.client;
    final db = AppDatabase.instance.db;
    final devId = await getDeviceId();

    // Query unsynced transaction headers
    final unsyncedTxns = await db.query('transactions', where: 'is_synced = 0');
    if (unsyncedTxns.isNotEmpty) {
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
        await client.from('transactions').upsert({
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
          await client.from('transaction_items').upsert(itemsPayload);
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
    
    // Pull cloud transactions to local database to absorb any online edits.
    final latestTxn = await db.query('transactions', columns: ['created_at'], orderBy: 'created_at DESC', limit: 1);
    String fetchAfter = '1970-01-01T00:00:00.000Z';
    if (latestTxn.isNotEmpty) {
      fetchAfter = latestTxn.first['created_at'] as String;
    }

    final List<dynamic> cloudTxns = await client.from('transactions').select().gt('created_at', fetchAfter);
    if (cloudTxns.isEmpty) return; // No new transactions to pull
    
    final List<String> newTxnIds = cloudTxns.map((e) => e['id'] as String).toList();
    final List<dynamic> cloudTxnItems = await client.from('transaction_items').select().inFilter('transaction_id', newTxnIds);

    await db.transaction((txn) async {
      for (final item in cloudTxns) {
        await txn.insert(
          'transactions',
          {
            'id': item['id'],
            'total_amount_cents': (item['total_amount_cents'] as num).toInt(),
            'total_items': (item['total_items'] as num).toInt(),
            'created_at': item['created_at'],
            'cashier_id': item['cashier_id'],
            'is_synced': 1,
          },
          conflictAlgorithm: ConflictAlgorithm.replace, // Overwrite local to reflect cloud edits
        );
      }
      for (final item in cloudTxnItems) {
        await txn.insert(
          'transaction_items',
          {
            'id': item['id'],
            'transaction_id': item['transaction_id'],
            'product_id': item['product_id'],
            'product_name': item['product_name'],
            'price_cents': (item['price_cents'] as num).toInt(),
            'quantity': (item['quantity'] as num).toInt(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace, // Overwrite local to reflect cloud edits
        );
      }
    });
    debugPrint('SyncEngine: Pulled ${cloudTxns.length} transactions from cloud.');
  }
}
