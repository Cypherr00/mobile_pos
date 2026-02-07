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
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create tables (v2 baseline schema)
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price_cents INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
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
        is_synced INTEGER NOT NULL DEFAULT 0
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
  }
}
