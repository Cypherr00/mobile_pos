// features/cart/cart_page.dart
// Cart UI with quantity control

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_provider.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.isEmpty
          ? const Center(child: Text('Cart is empty'))
          : ListView.builder(
        itemCount: cart.length,
        itemBuilder: (context, index) {
          final item = cart[index];
          return ListTile(
            title: Text(item.name),
            subtitle: Text('₱ ${(item.priceCents / 100).toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => cartNotifier.updateQuantity(
                    item.productId,
                    item.quantity - 1,
                  ),
                ),
                Text(item.quantity.toString()),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => cartNotifier.updateQuantity(
                    item.productId,
                    item.quantity + 1,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {}, // checkout wired in Phase 4
          child: const Text('Proceed to Checkout'),
        ),
      ),
    );
  }
}