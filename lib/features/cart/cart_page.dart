// features/cart/cart_page.dart
// Cart UI with quantity control

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_provider.dart';
import '../checkout/checkout_page.dart';
import '../../core/theme/app_colors.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    final totalItems = cart.fold<int>(0, (sum, item) => sum + item.quantity);
    final totalAmountCents =
    cart.fold<int>(0, (sum, item) => sum + (item.priceCents * item.quantity));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, cartNotifier, cart.isNotEmpty, totalItems),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 768),
            child: cart.isEmpty
                ? const _EmptyCartView()
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return _CartItemCard(item: item, cartNotifier: cartNotifier);
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : _CheckoutBottomBar(totalAmountCents: totalAmountCents),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context,
      dynamic cartNotifier,
      bool isNotEmpty,
      int totalItems,
      ) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shopping Cart',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: AppColors.textDark,
              letterSpacing: -0.5,
            ),
          ),
          if (isNotEmpty)
            Text(
              '$totalItems ${totalItems == 1 ? 'item' : 'items'} ready',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      actions: [
        if (isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: () => _showClearCartDialog(context, cartNotifier),
              icon: const Icon(Icons.delete_sweep_rounded, size: 20),
              label: const Text('Clear'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.danger,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showClearCartDialog(BuildContext context, dynamic cartNotifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Clear Cart?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        content: const Text(
          'Are you sure you want to remove all items from your cart? This action cannot be undone.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              cartNotifier.clear();
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final dynamic item;
  final dynamic cartNotifier;

  const _CartItemCard({
    required this.item,
    required this.cartNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final double unitPrice = item.priceCents / 100;
    final double itemTotal = (item.priceCents * item.quantity) / 100;

    return Dismissible(
      key: Key(item.productId),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.dangerLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.danger.withOpacity(0.35)),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Remove',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.delete_outline_rounded,
              color: AppColors.danger,
              size: 24,
            ),
          ],
        ),
      ),
      onDismissed: (_) {
        cartNotifier.updateQuantity(item.productId, 0);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} removed from cart'),
            backgroundColor: AppColors.textDark,
            action: SnackBarAction(
              label: 'Undo',
              textColor: AppColors.primaryLight,
              onPressed: () {
                cartNotifier.addItem(item);
              },
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.border,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.textDark.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top Row: Product details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Unit Price: ₱ ${unitPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border, height: 1, thickness: 1),
            const SizedBox(height: 12),
            
            // Bottom Row: Quantity adjusters & Subtotal for this item
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _QuantityButton(
                        icon: Icons.remove_rounded,
                        onTap: () => cartNotifier.updateQuantity(
                          item.productId,
                          item.quantity - 1,
                        ),
                      ),
                      Container(
                        constraints: const BoxConstraints(minWidth: 32),
                        alignment: Alignment.center,
                        child: Text(
                          item.quantity.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      _QuantityButton(
                        icon: Icons.add_rounded,
                        onTap: () => cartNotifier.updateQuantity(
                          item.productId,
                          item.quantity + 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLight,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₱ ${itemTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
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
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _CheckoutBottomBar extends StatelessWidget {
  final int totalAmountCents;

  const _CheckoutBottomBar({required this.totalAmountCents});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 768),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '₱ ${(totalAmountCents / 100).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total (VAT Inclusive)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        '₱ ${(totalAmountCents / 100).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryDark, AppColors.primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CheckoutPage(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Proceed to Checkout',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(width: 12),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.15),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Scan product QR codes or add them manually to start building your checkout.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
              label: const Text(
                'Start Scanning',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: AppColors.primary.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}