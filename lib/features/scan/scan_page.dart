// features/scan/scan_page.dart
// QR scanning with live preview before adding to cart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_providers.dart';
import '../../data/models/cart_item_model.dart';
import '../../core/theme/app_colors.dart';
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

  final MobileScannerController _controller = MobileScannerController(
    autoStart: true,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
        backgroundColor: Colors.transparent,
        builder: (_) => Container(
          decoration: const BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.danger,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Item Not Found',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Product ID: $code',
                    style: const TextStyle(color: AppColors.textLight, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AddProductPage()),
                        );
                        _isProcessing = false;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Register Product',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _isProcessing = false;
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textLight,
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
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
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Scan Code',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart_outlined, size: 26, color: Colors.white),
                if (cart.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        cart.fold<int>(0, (sum, item) => sum + item.quantity).toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
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
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Viewfinder Area
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _controller,
                  fit: BoxFit.cover,
                  onDetect: (capture) {
                    final code = capture.barcodes.first.rawValue;
                    if (code == null) return;
                    _handleScan(code);
                  },
                ),
                // Custom Viewfinder Overlay
                const _ViewfinderOverlay(),
              ],
            ),
          ),
          
          // Result Information Bar
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, -3),
                )
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: SafeArea(
              top: false,
              child: _productId == null
                  ? const _ScanPromptView()
                  : _buildProductPreviewCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductPreviewCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _productName!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SKU: $_productId',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '₱ ${(_priceCents! / 100).toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF34D399), // Highlighted green price
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            // Quantity buttons
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  _QuantityButton(
                    icon: Icons.remove_rounded,
                    onTap: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 36),
                    alignment: Alignment.center,
                    child: Text(
                      _quantity.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  _QuantityButton(
                    icon: Icons.add_rounded,
                    onTap: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Actions
            Expanded(
              child: SizedBox(
                height: 48,
                child: TextButton(
                  onPressed: _clearPreview,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        final String addedName = _productName ?? 'Item';
                        ref.read(cartProvider.notifier).addItem(
                              CartItem(
                                productId: _productId!,
                                name: _productName!,
                                priceCents: _priceCents!,
                                quantity: _quantity,
                              ),
                            );
                        _clearPreview();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added $addedName to cart'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: const Center(
                        child: Text(
                          'Add to Cart',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}

class _ScanPromptView extends StatelessWidget {
  const _ScanPromptView();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.qr_code_scanner_rounded,
            color: AppColors.primaryDark,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ready to scan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Place a product code inside the viewfinder window.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Camera Viewfinder Layout Overlay Custom Painter
class _ViewfinderOverlay extends StatelessWidget {
  const _ViewfinderOverlay();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        final double scanSize = width * 0.65; // viewfinder window box size

        final double left = (width - scanSize) / 2;
        final double top = (height - scanSize) / 2.3; // slightly offset upwards for balance
        final double right = left + scanSize;
        final double bottom = top + scanSize;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Darkened transparent background overlay surrounding the viewfinder box
            Positioned.fill(
              child: CustomPaint(
                painter: _OverlayPainter(
                  left: left,
                  top: top,
                  right: right,
                  bottom: bottom,
                ),
              ),
            ),
            
            // Neon Brackets at the corners of scanning box
            Positioned(
              left: left,
              top: top,
              width: scanSize,
              height: scanSize,
              child: const _ViewfinderBrackets(),
            ),
          ],
        );
      },
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final double left;
  final double top;
  final double right;
  final double bottom;

  _OverlayPainter({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.black.withOpacity(0.55);

    // Draw top region
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, top), paint);
    // Draw left region
    canvas.drawRect(Rect.fromLTRB(0, top, left, bottom), paint);
    // Draw right region
    canvas.drawRect(Rect.fromLTRB(right, top, size.width, bottom), paint);
    // Draw bottom region
    canvas.drawRect(Rect.fromLTRB(0, bottom, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ViewfinderBrackets extends StatelessWidget {
  const _ViewfinderBrackets();

  @override
  Widget build(BuildContext context) {
    const double bracketSize = 24.0;
    const double strokeWidth = 3.5;
    const Color color = Color(0xFF34D399); // Viewfinder line color (emerald green)

    return Stack(
      children: [
        // Top Left
        Positioned(
          left: 0,
          top: 0,
          child: Container(
            width: bracketSize,
            height: bracketSize,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: color, width: strokeWidth),
                left: BorderSide(color: color, width: strokeWidth),
              ),
            ),
          ),
        ),
        // Top Right
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            width: bracketSize,
            height: bracketSize,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: color, width: strokeWidth),
                right: BorderSide(color: color, width: strokeWidth),
              ),
            ),
          ),
        ),
        // Bottom Left
        Positioned(
          left: 0,
          bottom: 0,
          child: Container(
            width: bracketSize,
            height: bracketSize,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: color, width: strokeWidth),
                left: BorderSide(color: color, width: strokeWidth),
              ),
            ),
          ),
        ),
        // Bottom Right
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: bracketSize,
            height: bracketSize,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: color, width: strokeWidth),
                right: BorderSide(color: color, width: strokeWidth),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

