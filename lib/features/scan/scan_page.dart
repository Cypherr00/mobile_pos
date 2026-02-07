// features/scan/scan_page.dart
// QR scanning with unknown-product fallback

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_providers.dart';
import '../../data/models/cart_item_model.dart';
import '../products/add_product_page.dart';

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  bool _isProcessing = false;

  void _handleScan(String code) async {
    if (_isProcessing) return;
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
                      MaterialPageRoute(
                        builder: (_) => const AddProductPage(),
                      ),
                    );
                  },
                  child: const Text('Add Item'),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      ref.read(cartProvider.notifier).addItem(
        CartItem(
          productId: product.id,
          name: product.name,
          priceCents: product.priceCents,
          quantity: 1,
        ),
      );
    }

    await Future.delayed(const Duration(milliseconds: 600));
    _isProcessing = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Item')),
      body: MobileScanner(
        onDetect: (capture) {
          final code = capture.barcodes.first.rawValue;
          if (code == null) return;
          _handleScan(code);
        },
      ),
    );
  }
}
