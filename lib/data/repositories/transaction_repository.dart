// data/repositories/transaction_repository.dart
// Atomic checkout persistence

import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../models/transaction_model.dart';
import '../models/transaction_item_model.dart';
import '../models/cart_item_model.dart';

class TransactionRepository {
  final _db = AppDatabase.instance.db;
  final _uuid = const Uuid();

  Future<void> createTransaction(List<CartItem> cart) async {
    if (cart.isEmpty) return;

    final transactionId = _uuid.v4();
    final now = DateTime.now().toIso8601String();

    final totalItems = cart.fold(0, (s, e) => s + e.quantity);
    final totalAmount = cart.fold(0, (s, e) => s + (e.priceCents * e.quantity));

    final transaction = PosTransaction(
      id: transactionId,
      totalAmountCents: totalAmount,
      totalItems: totalItems,
      createdAt: now,
    );

    await _db.transaction((txn) async {
      await txn.insert('transactions', transaction.toMap());

      for (final item in cart) {
        final tItem = TransactionItem(
          id: _uuid.v4(),
          transactionId: transactionId,
          productId: item.productId,
          productName: item.name,
          priceCents: item.priceCents,
          quantity: item.quantity,
        );

        await txn.insert('transaction_items', tItem.toMap());
      }
    });
  }
}