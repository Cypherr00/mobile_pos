// features/loading/loading_page.dart
// App startup loading screen

import 'package:flutter/material.dart';
import '../main_menu/main_menu_page.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();

    // Simulate short startup delay for UX consistency
    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainMenuPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}