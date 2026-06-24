// core/database/app_database.dart
// Centralized SQLite initialization using sqflite

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  static Database? _db;

  Database get db {
    if (_db == null) {
      throw Exception('Database not initialized');
    }
    return _db!;
  }

  // Initialize database
  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mobile_qr_pos.db');

    _db = await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    await _bootstrapCashiers();
  }

  // Create tables (v2 baseline schema + Cashiers support)
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price_cents INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        version INTEGER NOT NULL DEFAULT 1,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        is_synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        total_amount_cents INTEGER NOT NULL,
        total_items INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        cashier_id TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE transaction_items (
        id TEXT PRIMARY KEY,
        transaction_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        price_cents INTEGER NOT NULL,
        quantity INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cashiers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        pin_hash TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'cashier',
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  // Upgrade path for existing local database files
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS cashiers (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          pin_hash TEXT NOT NULL,
          role TEXT NOT NULL DEFAULT 'cashier',
          is_active INTEGER NOT NULL DEFAULT 1,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      try {
        await db.execute('ALTER TABLE transactions ADD COLUMN cashier_id TEXT');
      } catch (_) {
        // column may already exist
      }
    }
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE products ADD COLUMN version INTEGER NOT NULL DEFAULT 1');
      } catch (_) {}
    }
    if (oldVersion < 4) {
      try {
        await db.execute('ALTER TABLE cashiers ADD COLUMN email TEXT NOT NULL DEFAULT ""');
      } catch (_) {}
    }
  }

  // Seeding default credentials for offline authentication availability
  Future<void> _bootstrapCashiers() async {
    final cashiers = await _db!.query('cashiers');
    if (cashiers.isEmpty) {
      final now = DateTime.now().toIso8601String();
      
      // Daven Admin
      await _db!.insert('cashiers', {
        'id': 'd7b1a206-bf25-4c07-8e68-07e0b5711200',
        'name': 'Daven Lozada',
        'email': 'davenjerthlozada@gmail.com',
        'pin_hash': '91b4d142823f7d20c5f08df69122de43f35f057a988d9619f6d3138485c9a203', // 1234
        'role': 'admin',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      });
    }
  }
}
