// features/main_menu/main_menu_page.dart
// Landing page with primary actions and dashboard layout

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../scan/scan_page.dart';
import '../products/add_product_page.dart';
import '../cart/cart_page.dart';
import '../products/manage_products_page.dart';
import '../transactions/transactions_page.dart';
import '../analytics/analytics_page.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Mobile POS',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        surfaceTintColor: Colors.transparent,
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: const [
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'POS Terminal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary),
              title: const Text('Scan Code', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ScanPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart_outlined, color: AppColors.primary),
              title: const Text('Shopping Cart', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CartPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
              title: const Text('Manage Products', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ManageProductsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
              title: const Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TransactionsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart_rounded, color: AppColors.primary),
              title: const Text('Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AnalyticsPage()),
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'v1.0.0 (Offline Mode)',
                style: TextStyle(color: AppColors.textLight, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Greeting Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Welcome Back,',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Cashier Station',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Main Quick Action (Scan Barcode Banner)
              _buildMainActionBanner(context),
              const SizedBox(height: 28),

              // Dashboard Section Title
              const Text(
                'Terminal Operations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),

              // Actions Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.25,
                children: [
                  _buildMenuCard(
                    context,
                    title: 'Shopping Cart',
                    subtitle: 'Review & Checkout',
                    icon: Icons.shopping_cart_rounded,
                    color: AppColors.primary,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Transactions',
                    subtitle: 'Sales & Receipts',
                    icon: Icons.receipt_long_rounded,
                    color: AppColors.primary,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TransactionsPage()),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Add Product',
                    subtitle: 'Create Manual Item',
                    icon: Icons.add_circle_outline_rounded,
                    color: AppColors.primary,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddProductPage()),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Manage Products',
                    subtitle: 'Product Catalogue',
                    icon: Icons.inventory_2_rounded,
                    color: AppColors.primary,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ManageProductsPage()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Full-Width Analytics Shortcut Card
              _buildAnalyticsCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainActionBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ScanPage()),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'FAST QR SCANNER',
                        style: TextStyle(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Scan Barcode / QR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Add items directly using phone camera',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 22,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AnalyticsPage()),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    color: AppColors.accent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Sales Analytics',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'View metrics on sales & revenue stats',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
