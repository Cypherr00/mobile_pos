// features/products/add_product_page.dart
// Manual product creation screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../../providers/product_providers.dart';

class AddProductPage extends ConsumerStatefulWidget {
  const AddProductPage({super.key});

  @override
  ConsumerState<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends ConsumerState<AddProductPage> {
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final id = _idController.text.trim();
    final name = _nameController.text.trim();
    final price = int.tryParse(_priceController.text) ?? 0;

    if (id.isEmpty || name.isEmpty) return;

    final product = Product(
      id: id,
      name: name,
      priceCents: price,
      isDeleted: false,
    );

    final repo = ref.read(productRepositoryProvider);
    await repo.upsert(product);

    await ref.read(productListProvider.notifier).refresh();

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: const InputDecoration(labelText: 'Product ID'),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price (cents)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
