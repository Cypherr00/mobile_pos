// providers/transaction_provider.dart
// Checkout orchestration provider

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/transaction_repository.dart';
import 'cart_provider.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

final checkoutProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final cart = ref.read(cartProvider);
    final repo = ref.read(transactionRepositoryProvider);

    await repo.createTransaction(cart);

    ref.read(cartProvider.notifier).clear();
  };
});
