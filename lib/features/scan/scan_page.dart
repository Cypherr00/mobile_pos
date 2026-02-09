// features/scan/scan_page.dart
// QR scanning with live preview before adding to cart
// Replaces previous immediate-add scan behavior

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/features/scan/scan_page.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_providers.dart';
import '../../data/models/cart_item_model.dart';
import '../products/add_product_page.dart';
import '../cart/cart_page.dart';

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  bool _isProcessing = false;

  String? _productId;
  String? _productName;
  int? _priceCents;
  int _quantity = 1;

  void _clearPreview() {
    setState(() {
      _productId = null;
      _productName = null;
      _priceCents = null;
      _quantity = 1;
      _isProcessing = false;
    });
  }

  Future<void> _handleScan(String code) async {
    if (_isProcessing || _productId != null) return;
    _isProcessing = true;

    final repo = ref.read(productRepositoryProvider);
    final product = await repo.getById(code);

    if (!mounted) return;

    if (product == null) {
      showModalBottomSheet(
        context: context,
        builder: (_) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Item not found'),
                const SizedBox(height: 8),
                Text('Product ID: $code'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddProductPage()),
                    );
                    _isProcessing = false;
                  },
                  child: const Text('Add Item'),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    setState(() {
      _productId = product.id;
      _productName = product.name;
      _priceCents = product.priceCents;
      _quantity = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Item'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (cart.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        cart.length.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              onDetect: (capture) {
                final code = capture.barcodes.first.rawValue;
                if (code == null) return;
                _handleScan(code);
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: _productId == null
                ? const Center(child: Text('Scan a product QR code'))
                : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(_productName!, style: const TextStyle(fontSize: 18)),
                  Text('ID: $_productId'),
                  const SizedBox(height: 8),
                  Text(
                    '₱ ${(_priceCents! / 100).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (_quantity > 1) setState(() => _quantity--);
                        },
                      ),
                      Text(_quantity.toString(), style: const TextStyle(fontSize: 20)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _clearPreview,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(cartProvider.notifier).addItem(
                              CartItem(
                                productId: _productId!,
                                name: _productName!,
                                priceCents: _priceCents!,
                                quantity: _quantity,
                              ),
                            );
                            _clearPreview();
                          },
                          child: const Text('Add to Cart'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
