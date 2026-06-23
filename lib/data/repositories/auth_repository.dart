// data/repositories/auth_repository.dart

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../models/cashier_model.dart';

class AuthRepository {
  Database get _db => AppDatabase.instance.db;

  // Hashes PIN with SHA-256
  String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Retrieve cached cashiers from local SQLite
  Future<List<Cashier>> getLocalCashiers() async {
    final result = await _db.query('cashiers', where: 'is_active = 1', orderBy: 'name ASC');
    return result.map(Cashier.fromMap).toList();
  }

  // Verify PIN locally for a specific cashier
  Future<bool> verifyPin(String cashierId, String pin) async {
    final hashed = hashPin(pin);
    final result = await _db.query(
      'cashiers',
      where: 'id = ? AND pin_hash = ? AND is_active = 1',
      whereArgs: [cashierId, hashed],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Verify if a PIN belongs to an active Admin user (for action overrides)
  Future<bool> verifyAdminPin(String pin) async {
    final hashed = hashPin(pin);
    final result = await _db.query(
      'cashiers',
      where: 'role = ? AND pin_hash = ? AND is_active = 1',
      whereArgs: ['admin', hashed],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
