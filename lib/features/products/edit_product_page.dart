// features/products/edit_product_page.dart
// Edit existing product (price/name only)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../../providers/product_providers.dart';

class EditProductPage extends ConsumerStatefulWidget {
  final Product product;

  const EditProductPage({super.key, required this.product});

  @override
  ConsumerState<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends ConsumerState<EditProductPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.priceCents.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final updated = Product(
      id: widget.product.id,
      name: _nameController.text.trim(),
      priceCents: int.tryParse(_priceController.text) ?? widget.product.priceCents,
      isDeleted: false,
    );

    final repo = ref.read(productRepositoryProvider);
    await repo.upsert(updated);

    await ref.read(productListProvider.notifier).refresh();

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Item')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Product ID: ${widget.product.id}'),
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
            ElevatedButton(onPressed: _save, child: const Text('Save Changes')),
          ],
        ),
      ),
    );
  }
}
