// providers/product_providers.dart
// Riverpod 3.2.1 AsyncNotifier-based providers

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/product_model.dart';
import '../data/repositories/product_repository.dart';
import 'package:sqflite/sqflite.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

class ProductListNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    final repo = ref.read(productRepositoryProvider);
    return repo.getAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await build());
  }
}

final productListProvider = AsyncNotifierProvider<ProductListNotifier, List<Product>>(
  ProductListNotifier.new,
);
