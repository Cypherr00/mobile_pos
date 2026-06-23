// providers/transaction_provider.dart
// Checkout orchestration provider

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/transaction_repository.dart';
import 'cart_provider.dart';
import 'auth_provider.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

final checkoutProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final cart = ref.read(cartProvider);
    final repo = ref.read(transactionRepositoryProvider);
    final activeCashier = ref.read(authProvider).activeCashier;

    await repo.createTransaction(cart, cashierId: activeCashier?.id);

    ref.read(cartProvider.notifier).clear();
  };
});
