// features/auth/widgets/admin_auth_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';

class AdminAuthorizationDialog extends ConsumerStatefulWidget {
  final String message;

  const AdminAuthorizationDialog({
    super.key,
    this.message = 'Admin override authorization is required to perform this action.',
  });

  @override
  ConsumerState<AdminAuthorizationDialog> createState() => _AdminAuthorizationDialogState();

  // Helper static builder to show validation overlay
  static Future<bool> show(BuildContext context, {String message = 'Admin override authorization is required to perform this action.'}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AdminAuthorizationDialog(message: message),
    );
    return result ?? false;
  }
}

class _AdminAuthorizationDialogState extends ConsumerState<AdminAuthorizationDialog> {
  final List<String> _pinChars = [];
  bool _isError = false;
  bool _isVerifying = false;

  void _onKeyPress(String val) {
    if (_pinChars.length < 6) {
      setState(() {
        _isError = false;
        _pinChars.add(val);
      });
      if (_pinChars.length >= 4) {
        // Automatically check when minimum pin entered
      }
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
    final isAuthorized = await ref.read(authProvider.notifier).authorizeAdminAction(pin);

    if (!mounted) return;

    if (isAuthorized) {
      Navigator.of(context).pop(true);
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
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_person_rounded,
                color: AppColors.danger,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            
            // Header
            const Text(
              'Admin Authorization',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // PIN Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                final hasChar = index < _pinChars.length;
                return Container(
                  width: 16,
                  height: 16,
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
                'Invalid Admin PIN code.',
                style: TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.bold),
              )
            else if (_isVerifying)
              const Text(
                'Verifying...',
                style: TextStyle(color: AppColors.primary, fontSize: 12),
              )
            else
              const SizedBox(height: 18),
            
            const SizedBox(height: 12),

            // Numerical keypad layout
            SizedBox(
              width: 240,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 12,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.25,
                ),
                itemBuilder: (context, index) {
                  // Key logic
                  if (index == 9) {
                    // Backspace
                    return IconButton(
                      onPressed: _onBackspace,
                      icon: const Icon(Icons.backspace_outlined, color: AppColors.textDark),
                    );
                  } else if (index == 10) {
                    // Number 0
                    return _buildKeyButton('0');
                  } else if (index == 11) {
                    // Verify submit
                    return IconButton(
                      onPressed: _onSubmit,
                      icon: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
                    );
                  } else {
                    // Numbers 1 to 9
                    final number = (index + 1).toString();
                    return _buildKeyButton(number);
                  }
                },
              ),
            ),
            
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyButton(String label) {
    return InkWell(
      onTap: () => _onKeyPress(label),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ),
    );
  }
}
