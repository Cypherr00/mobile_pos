// features/auth/cashier_selection_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sync_provider.dart';
import 'pin_entry_page.dart';

class CashierSelectionPage extends ConsumerStatefulWidget {
  const CashierSelectionPage({super.key});

  @override
  ConsumerState<CashierSelectionPage> createState() => _CashierSelectionPageState();
}

class _CashierSelectionPageState extends ConsumerState<CashierSelectionPage> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    final cashiersAsync = ref.watch(cashiersListProvider);
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connection Status Banner
              if (authState.isOffline)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.danger.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.wifi_off_rounded, color: AppColors.danger, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Offline Mode Active. Terminal using local cached logins.',
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

              // Headers
              Row(
                children: [
                  Visibility(
                    visible: _selectedRole != null,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: () => setState(() => _selectedRole = null),
                        color: AppColors.textDark,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                  const Text(
                    'Vendr POS Terminal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _selectedRole == null 
                    ? 'Select Role' 
                    : 'Select ${_selectedRole == 'admin' ? 'Admin' : 'Cashier'} Account',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _selectedRole == null
                          ? 'Choose your role to view available accounts.'
                          : 'Choose your account to open the PIN authentication pad.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (!authState.isOffline)
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: Center(
                        child: syncState.isSyncing
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.primary,
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: () async {
                                    await ref.read(syncProvider.notifier).sync();
                                    ref.invalidate(cashiersListProvider);
                                  },
                                  icon: const Icon(Icons.sync_rounded),
                                  color: AppColors.primary,
                                  iconSize: 20,
                                  tooltip: 'Sync Accounts',
                                ),
                              ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 36),

              // Main Content Area
              Expanded(
                child: _selectedRole == null
                    ? _buildRoleSelection()
                    : _buildAccountSelection(cashiersAsync),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      children: [
        _buildRoleCard(
          title: 'Admin',
          icon: Icons.admin_panel_settings_rounded,
          color: AppColors.accent,
          role: 'admin',
        ),
        const SizedBox(height: 16),
        _buildRoleCard(
          title: 'Cashier',
          icon: Icons.point_of_sale_rounded,
          color: AppColors.primary,
          role: 'cashier',
        ),
      ],
    );
  }

  Widget _buildRoleCard({required String title, required IconData icon, required Color color, required String role}) {
    return InkWell(
      onTap: () => setState(() => _selectedRole = role),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSelection(AsyncValue cashiersAsync) {
    return cashiersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (err, _) => Center(child: Text('Failed to load accounts: $err', style: const TextStyle(color: AppColors.danger))),
      data: (allCashiers) {
        final filtered = allCashiers.where((c) => c.role == _selectedRole).toList();
        if (filtered.isEmpty) {
          return Center(
            child: Text(
              'No ${_selectedRole}s found. Please sync.',
              style: const TextStyle(color: AppColors.textMuted),
            ),
          );
        }

        return GridView.builder(
          itemCount: filtered.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, index) {
            final cashier = filtered[index];
            final isAdmin = cashier.isAdmin;
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border, width: 1.5),
                boxShadow: [
                  BoxShadow(color: AppColors.textDark.withOpacity(0.015), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    await ref.read(authProvider.notifier).selectCashier(cashier);
                    if (context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PinEntryPage()),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (isAdmin ? AppColors.accent : AppColors.primary).withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                            color: isAdmin ? AppColors.accent : AppColors.primary,
                            size: 24,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cashier.name,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cashier.email,
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
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
          },
        );
      },
    );
  }
}
