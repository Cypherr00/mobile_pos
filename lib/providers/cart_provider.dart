// providers/cart_provider.dart
// Cart state management using Notifier (Riverpod 3.x)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/cart_item_model.dart';

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void addItem(CartItem item) {
    final index = state.indexWhere((e) => e.productId == item.productId);
    if (index >= 0) {
      final existing = state[index];
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            existing.copyWith(quantity: existing.quantity + item.quantity)
          else
            state[i]
      ];
    } else {
      state = [...state, item];
    }
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      state = state.where((e) => e.productId != productId).toList();
      return;
    }

    state = state
        .map((e) => e.productId == productId ? e.copyWith(quantity: quantity) : e)
        .toList();
  }

  void clear() {
    state = [];
  }

  int get totalItems => state.fold(0, (sum, e) => sum + e.quantity);

  int get totalAmountCents =>
      state.fold(0, (sum, e) => sum + (e.priceCents * e.quantity));
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);
