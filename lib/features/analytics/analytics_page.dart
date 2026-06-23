// features/analytics/analytics_page.dart
// Simple analytics dashboard (offline) using AppColors

import 'package:flutter/material.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_colors.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  Future<Map<String, int>> _load() async {
    final db = AppDatabase.instance.db;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as transactions,
        SUM(total_items) as items,
        SUM(total_amount_cents) as revenue
      FROM transactions
    ''');

    final row = result.first;
    return {
      'transactions': row['transactions'] as int? ?? 0,
      'items': row['items'] as int? ?? 0,
      'revenue': row['revenue'] as int? ?? 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        surfaceTintColor: Colors.transparent,
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _load(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final data = snapshot.data ?? {'transactions': 0, 'items': 0, 'revenue': 0};
          final hasSales = data['transactions']! > 0;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Performance Metrics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Lifetime sales and transaction figures recorded locally.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Revenue Card (Large, Primary Style)
                  _buildStatCard(
                    title: 'TOTAL REVENUE',
                    value: '₱ ${(data['revenue']! / 100).toStringAsFixed(2)}',
                    icon: Icons.payments_rounded,
                    backgroundColor: Colors.white,
                    textColor: AppColors.primary,
                    iconColor: AppColors.primary,
                    isLarge: true,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      // Transactions Card
                      Expanded(
                        child: _buildStatCard(
                          title: 'TRANSACTIONS',
                          value: '${data['transactions']}',
                          icon: Icons.receipt_long_rounded,
                          backgroundColor: Colors.white,
                          textColor: AppColors.textDark,
                          iconColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Items Sold Card
                      Expanded(
                        child: _buildStatCard(
                          title: 'ITEMS SOLD',
                          value: '${data['items']}',
                          icon: Icons.inventory_2_rounded,
                          backgroundColor: Colors.white,
                          textColor: AppColors.textDark,
                          iconColor: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  if (!hasSales) ...[
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.trending_up_rounded,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No sales activity yet',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text(
                              'Complete sales transactions on the terminal to generate reports here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Offline POS Database is synchronized and up to date.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    required Color iconColor,
    bool isLarge = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isLarge ? 24 : 20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: isLarge ? 22 : 18,
                ),
              ),
            ],
          ),
          SizedBox(height: isLarge ? 12 : 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isLarge ? 28 : 22,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
