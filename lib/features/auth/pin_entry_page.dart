// features/auth/pin_entry_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../main_menu/main_menu_page.dart';

import 'cashier_selection_page.dart';

class PinEntryPage extends ConsumerStatefulWidget {
  const PinEntryPage({super.key});

  @override
  ConsumerState<PinEntryPage> createState() => _PinEntryPageState();
}

class _PinEntryPageState extends ConsumerState<PinEntryPage> {
  final List<String> _pinChars = [];
  bool _isError = false;
  bool _isVerifying = false;

  void _onKeyPress(String val) {
    if (_pinChars.length < 6) {
      setState(() {
        _isError = false;
        _pinChars.add(val);
      });
    }
  }

  void _onBackspace() {
    if (_pinChars.isNotEmpty) {
      setState(() {
        _isError = false;
        _pinChars.removeLast();
      });
    }
  }

  Future<void> _onSubmit() async {
    if (_pinChars.isEmpty) return;
    setState(() => _isVerifying = true);

    final pin = _pinChars.join();
    final success = await ref.read(authProvider.notifier).login(pin);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainMenuPage()),
        (route) => false,
      );
    } else {
      setState(() {
        _isVerifying = false;
        _isError = true;
        _pinChars.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final cashiersAsync = ref.watch(cashiersListProvider);

    // Resolve current selected cashier details
    final cashier = cashiersAsync.whenOrNull(
      data: (list) {
        try {
          return list.firstWhere((c) => c.id == authState.selectedCashierId);
        } catch (_) {
          return null;
        }
      },
    );

    final String name = cashier?.name ?? 'Loading...';
    final bool isAdmin = cashier?.isAdmin ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Connection Status Banner
            if (authState.isOffline)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppColors.dangerLight,
                child: Row(
                  children: const [
                    Icon(Icons.wifi_off_rounded, color: AppColors.danger, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Offline Mode Active. Cashier account switches disabled.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    // Lock icon avatar
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                        color: AppColors.primary,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Greeting
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isAdmin ? 'Administrator Authentication' : 'Enter Cashier PIN',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Dots Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        final hasChar = index < _pinChars.length;
                        return Container(
                          width: 18,
                          height: 18,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isError
                                ? AppColors.danger
                                : (hasChar ? AppColors.primary : AppColors.border),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    if (_isError)
                      const Text(
                        'Invalid PIN code. Please try again.',
                        style: TextStyle(color: AppColors.danger, fontSize: 13, fontWeight: FontWeight.bold),
                      )
                    else if (_isVerifying)
                      const Text(
                        'Authorizing POS access...',
                        style: TextStyle(color: AppColors.primary, fontSize: 13),
                      )
                    else
                      const SizedBox(height: 19),

                    const SizedBox(height: 24),

                    // Keypad
                    SizedBox(
                      width: 270,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 12,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.25,
                        ),
                        itemBuilder: (context, index) {
                          if (index == 9) {
                            return IconButton(
                              onPressed: _onBackspace,
                              icon: const Icon(Icons.backspace_outlined, color: AppColors.textDark, size: 22),
                            );
                          } else if (index == 10) {
                            return _buildKeyButton('0');
                          } else if (index == 11) {
                            return IconButton(
                              onPressed: _onSubmit,
                              icon: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 36),
                            );
                          } else {
                            return _buildKeyButton((index + 1).toString());
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Back/Switch User button (DISABLED when offline)
                    if (!authState.isOffline)
                      TextButton.icon(
                        onPressed: () async {
                          final success = await ref.read(authProvider.notifier).switchCashier();
                          if (success && context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const CashierSelectionPage()),
                              (route) => false,
                            );
                          }
                        },
                        icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                        label: const Text(
                          'Switch Cashier Profile',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyButton(String label) {
    return InkWell(
      onTap: () => _onKeyPress(label),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ),
    );
  }
}
