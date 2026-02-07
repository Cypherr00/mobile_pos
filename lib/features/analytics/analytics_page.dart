// features/analytics/analytics_page.dart
// Simple analytics dashboard (offline)

import 'package:flutter/material.dart';
import '../../core/database/app_database.dart';

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
      appBar: AppBar(title: const Text('Analytics')),
      body: FutureBuilder<Map<String, int>>(
        future: _load(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Transactions: ${data['transactions']}'),
                Text('Items Sold: ${data['items']}'),
                Text('Revenue: ₱ ${(data['revenue']! / 100).toStringAsFixed(2)}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
