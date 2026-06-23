// features/loading/loading_page.dart
// App startup loading screen checking auth state

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../auth/cashier_selection_page.dart';
import '../auth/pin_entry_page.dart';
import '../../core/theme/app_colors.dart';

class LoadingPage extends ConsumerStatefulWidget {
  const LoadingPage({super.key});

  @override
  ConsumerState<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends ConsumerState<LoadingPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait a brief moment for the AuthNotifier initialization from SharedPreferences
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (!mounted) return;
    
    final authState = ref.read(authProvider);

    if (authState.selectedCashierId == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CashierSelectionPage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PinEntryPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}