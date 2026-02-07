// features/transactions/transactions_page.dart
// Transaction history (basic list)

import 'package:flutter/material.dart';
import '../../core/database/app_database.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  Future<List<Map<String, dynamic>>> _load() async {
    final db = AppDatabase.instance.db;
    return db.query('transactions', orderBy: 'created_at DESC');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: FutureBuilder(
        future: _load(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!;
          if (data.isEmpty) return const Center(child: Text('No transactions yet'));

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final t = data[index];
              return ListTile(
                title: Text('₱ ${(t['total_amount_cents'] / 100).toStringAsFixed(2)}'),
                subtitle: Text(t['created_at']),
              );
            },
          );
        },
      ),
    );
  }
}