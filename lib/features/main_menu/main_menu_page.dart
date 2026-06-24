// features/main_menu/main_menu_page.dart
// Landing page with primary actions and dashboard layout

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sync_provider.dart';
import '../scan/scan_page.dart';
import '../products/add_product_page.dart';
import '../cart/cart_page.dart';
import '../products/manage_products_page.dart';
import '../transactions/transactions_page.dart';
import '../analytics/analytics_page.dart';
import '../loading/loading_page.dart';
import '../auth/widgets/admin_auth_dialog.dart';

class MainMenuPage extends ConsumerWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final syncState = ref.watch(syncProvider);

    ref.listen<SyncState>(syncProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync Error: ${next.errorMessage}'),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      if (previous?.isSyncing == true && next.isSyncing == false && next.errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sync completed successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });

    final String cashierName = authState.activeCashier?.name ?? 'Cashier Station';
    final String cashierRole = authState.activeCashier?.role ?? 'cashier';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Vendr',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        surfaceTintColor: Colors.transparent,
        actions: [
          Tooltip(
            message: authState.isOffline ? 'Offline Mode (Local database active)' : 'Online Mode (Supabase connected)',
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (authState.isOffline ? AppColors.danger : AppColors.success).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                authState.isOffline ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
                color: authState.isOffline ? AppColors.danger : AppColors.success,
                size: 20,
              ),
            ),
          ),
        ],
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.storefront_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Vendr POS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$cashierName (${cashierRole.toUpperCase()})',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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
              trailing: cashierRole != 'admin'
                  ? const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.textLight)
                  : null,
              onTap: () async {
                Navigator.of(context).pop();
                bool authorized = cashierRole == 'admin';
                if (!authorized) {
                  authorized = await AdminAuthorizationDialog.show(
                    context,
                    message: 'Admin credentials are required to manage products.',
                  );
                }
                if (authorized && context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ManageProductsPage(isAdminAuthorized: true)),
                  );
                }
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
              trailing: cashierRole != 'admin'
                  ? const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.textLight)
                  : null,
              onTap: () async {
                Navigator.of(context).pop();
                bool authorized = cashierRole == 'admin';
                if (!authorized) {
                  authorized = await AdminAuthorizationDialog.show(
                    context,
                    message: 'Admin credentials are required to view performance analytics.',
                  );
                }
                if (authorized && context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AnalyticsPage()),
                  );
                }
              },
            ),
            const Divider(color: AppColors.border),

            // Sync Database Option (only enabled when online)
            if (!authState.isOffline)
              ListTile(
                leading: ref.watch(syncProvider).isSyncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Icon(Icons.sync_rounded, color: AppColors.primary),
                title: const Text('Sync Database', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () async {
                  if (ref.read(syncProvider).isSyncing) return;
                  
                  await ref.read(syncProvider.notifier).sync();
                  
                  if (context.mounted) {
                    final error = ref.read(syncProvider).errorMessage;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error ?? 'Sync completed successfully!'),
                        backgroundColor: error != null ? AppColors.danger : AppColors.success,
                      ),
                    );
                    Navigator.of(context).pop(); // Close drawer
                  }
                },
              ),

            // Switch Cashier Profile Option (only enabled when online)
            if (!authState.isOffline)
              ListTile(
                leading: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
                title: const Text('Switch Cashier', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () async {
                  final success = await ref.read(authProvider.notifier).switchCashier();
                  if (success && context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoadingPage()),
                      (route) => false,
                    );
                  }
                },
              ),
              
            // Logout Option
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
              title: const Text(
                'Logout', 
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger)
              ),
              onTap: () {
                ref.read(authProvider.notifier).logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoadingPage()),
                  (route) => false,
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                authState.isOffline ? 'v1.0.0 (Offline Mode)' : 'v1.0.0 (Cloud Synced)',
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
                    children: [
                      const Text(
                        'Welcome Back,',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cashierName,
                        style: const TextStyle(
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
                    isLocked: cashierRole != 'admin',
                    onTap: () async {
                      bool authorized = cashierRole == 'admin';
                      if (!authorized) {
                        authorized = await AdminAuthorizationDialog.show(
                          context,
                          message: 'Admin credentials are required to add products.',
                        );
                      }
                      if (authorized && context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AddProductPage(isAdminAuthorized: true),
                          ),
                        );
                      }
                    },
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Manage Products',
                    subtitle: 'Product Catalogue',
                    icon: Icons.inventory_2_rounded,
                    color: AppColors.primary,
                    isLocked: cashierRole != 'admin',
                    onTap: () async {
                      bool authorized = cashierRole == 'admin';
                      if (!authorized) {
                        authorized = await AdminAuthorizationDialog.show(
                          context,
                          message: 'Admin credentials are required to manage products.',
                        );
                      }
                      if (authorized && context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ManageProductsPage(isAdminAuthorized: true),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Full-Width Analytics Shortcut Card
              _buildAnalyticsCard(context, isLocked: cashierRole != 'admin'),
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
    bool isLocked = false,
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
                Row(
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
                    if (isLocked)
                      const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.textLight,
                        size: 16,
                      ),
                  ],
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

  Widget _buildAnalyticsCard(BuildContext context, {required bool isLocked}) {
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
          onTap: () async {
            bool authorized = !isLocked;
            if (!authorized) {
              authorized = await AdminAuthorizationDialog.show(
                context,
                message: 'Admin credentials are required to view performance analytics.',
              );
            }
            if (authorized && context.mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AnalyticsPage()),
              );
            }
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
                Icon(
                  isLocked ? Icons.lock_outline_rounded : Icons.chevron_right_rounded,
                  color: AppColors.textLight,
                  size: isLocked ? 18 : 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
