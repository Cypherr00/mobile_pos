import 'dart:math';
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
  final List<String> _tips = [
    "Connect to the database daily to ensure updated prices.",
    "Sync before starting your shift to get the latest product catalog.",
    "Offline sales are saved locally and synced when you reconnect.",
  ];
  late final String _currentTip;

  @override
  void initState() {
    super.initState();
    _currentTip = _tips[Random().nextInt(_tips.length)];
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait a brief moment for the AuthNotifier initialization from SharedPreferences
    await Future.delayed(const Duration(milliseconds: 1500));
    
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/assets/VendrLogo.png',
                    width: 120,
                  ),
                  const SizedBox(height: 48),
                  const CircularProgressIndicator(color: AppColors.primary),
                ],
              ),
            ),
            Positioned(
              bottom: 40,
              left: 32,
              right: 32,
              child: Column(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, color: AppColors.textMuted, size: 24),
                  const SizedBox(height: 12),
                  Text(
                    _currentTip,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}