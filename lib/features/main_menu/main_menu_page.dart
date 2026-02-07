// features/main_menu/main_menu_page.dart
// Landing page with primary actions

import 'package:flutter/material.dart';
import '../scan/scan_page.dart';
import '../products/add_product_page.dart';
import '../cart/cart_page.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mobile QR POS')),
      drawer: Drawer(
        child: ListView(
          children: const [
            DrawerHeader(child: Text('Menu')),
            ListTile(title: Text('Manage Products')),
            ListTile(title: Text('Transactions')),
            ListTile(title: Text('Analytics')),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ScanPage()),
                );

              },
              child: const Text('Scan Item'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddProductPage()),
                );

              },
              child: const Text('Add Item'), // Manual add entry point
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CartPage()),
                );

              },
              child: const Text('Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
