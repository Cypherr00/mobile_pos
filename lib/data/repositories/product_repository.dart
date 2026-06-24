// data/repositories/product_repository.dart
// Single source of truth for product CRUD

import 'package:sqflite/sqflite.dart';

import '../../core/database/app_database.dart';
import '../models/product_model.dart';

class ProductRepository {
  Database get _db => AppDatabase.instance.db;

  Future<Product?> getById(String id) async {
    final result = await _db.query(
      'products',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Product.fromMap(result.first);
  }

  Future<List<Product>> getAll() async {
    final result = await _db.query(
      'products',
      where: 'is_deleted = 0',
      orderBy: 'name ASC',
    );

    return result.map(Product.fromMap).toList();
  }

  Future<void> upsert(Product product) async {
    final existing = await getById(product.id);
    final versionToSave = existing != null ? existing.version + 1 : product.version;

    final map = product.toMap();
    map['version'] = versionToSave;

    await _db.insert(
      'products',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> softDelete(String id) async {
    final existing = await getById(id);
    if (existing == null) return;

    await _db.update(
      'products',
      {
        'is_deleted': 1,
        'version': existing.version + 1,
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}