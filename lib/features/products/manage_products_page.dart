// features/products/manage_products_page.dart
// Product list with edit access (soft-delete safe) and AppColors integration

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_providers.dart';
import '../../core/theme/app_colors.dart';
import 'edit_product_page.dart';
import 'add_product_page.dart';

class ManageProductsPage extends ConsumerWidget {
  const ManageProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Manage Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        surfaceTintColor: Colors.transparent,
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Error loading catalogue: $e',
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ),
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.inventory_2_rounded,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Catalogue is empty',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Register products manually to begin scanning or selling.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AddProductPage()),
                        );
                      },
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Add First Item', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textDark.withOpacity(0.015),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textDark,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'SKU: ${product.id}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₱ ${(product.priceCents / 100).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textLight,
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EditProductPage(product: product),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddProductPage()),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Item', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
