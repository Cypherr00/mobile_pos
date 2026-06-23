// features/checkout/checkout_page.dart
// Checkout confirmation screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/transaction_provider.dart';

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return ListTile(
                  title: Text(item.name),
                  trailing: Text('x${item.quantity}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Items: ${cart.fold<int>(0, (sum, item) => sum + item.quantity)}'),
                Text('Total: ₱ ${(cart.fold<int>(0, (sum, item) => sum + (item.priceCents * item.quantity)) / 100).toStringAsFixed(2)}'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(checkoutProvider)();
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text('Confirm Sale'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}