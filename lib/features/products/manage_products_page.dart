// features/products/manage_products_page.dart
// Product list with edit access (soft-delete safe)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_providers.dart';
import 'edit_product_page.dart';

class ManageProductsPage extends ConsumerWidget {
  const ManageProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Products')),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text('₱ ${(product.priceCents / 100).toStringAsFixed(2)}'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditProductPage(product: product),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
