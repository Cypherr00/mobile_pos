// providers/auth_provider.dart

import 'dart:async';
import 'package:mobile_pos/core/network/supabase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../data/models/cashier_model.dart';
import '../data/repositories/auth_repository.dart';
import '../core/sync/sync_engine.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final cashiersListProvider = FutureProvider<List<Cashier>>((ref) async {
  return ref.watch(authRepositoryProvider).getLocalCashiers();
});

class AuthState {
  final String? selectedCashierId;
  final Cashier? activeCashier;
  final bool isOffline;
  final bool isInitialized;

  AuthState({
    this.selectedCashierId,
    this.activeCashier,
    this.isOffline = false,
    this.isInitialized = false,
  });

  AuthState copyWith({
    String? selectedCashierId,
    Cashier? activeCashier,
    bool? isOffline,
    bool? isInitialized,
    bool clearActiveCashier = false,
    bool clearSelectedCashier = false,
  }) {
    return AuthState(
      selectedCashierId: clearSelectedCashier ? null : (selectedCashierId ?? this.selectedCashierId),
      activeCashier: clearActiveCashier ? null : (activeCashier ?? this.activeCashier),
      isOffline: isOffline ?? this.isOffline,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  static const _prefKey = 'selected_cashier_id';

  @override
  AuthState build() {
    _init();
    ref.onDispose(() {
      _connectivitySub?.cancel();
    });
    return AuthState();
  }

  Future<void> _init() async {
    // 1. Load saved session from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_prefKey);

    // 2. Setup Connectivity listener
    final connectivity = Connectivity();
    final initialResults = await connectivity.checkConnectivity();
    final isOffline = _checkIsOffline(initialResults);

    state = AuthState(
      selectedCashierId: savedId,
      isOffline: isOffline,
      isInitialized: true,
    );

    _connectivitySub = connectivity.onConnectivityChanged.listen((results) {
      final newOffline = _checkIsOffline(results);
      final wasOffline = state.isOffline;
      state = state.copyWith(isOffline: newOffline);
      if (wasOffline && !newOffline) {
        // Network connection restored, sync all unsynced data in background
        SyncEngine.instance.syncAll();
      }
    });
  }

  bool _checkIsOffline(List<ConnectivityResult> results) {
    if (results.isEmpty) return true;
    if (results.contains(ConnectivityResult.none)) return true;
    return false;
  }

  // Choose a cashier profile (saves to SharedPreferences)
  Future<void> selectCashier(Cashier cashier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, cashier.id);
    state = state.copyWith(selectedCashierId: cashier.id);
  }

  // Attempt login with PIN for the selected cashier
  Future<bool> login(String pin) async {
    final cashierId = state.selectedCashierId;
    if (cashierId == null) return false;

    final repo = ref.read(authRepositoryProvider);
    
    // OFFLINE & ONLINE: Use local SQLite hash
    // The local cashiers table is always synced with Supabase in the background,
    // so we can rely strictly on the cashiers table.
    final isValid = await repo.verifyPin(cashierId, pin);
    if (!isValid) return false;

    // Load cashier details to set active session
    final cashiers = await repo.getLocalCashiers();
    final cashier = cashiers.firstWhere((c) => c.id == cashierId);

    state = state.copyWith(activeCashier: cashier);
    return true;
  }

  // Clear active login session but keep the remembered profile selection
  void logout() {
    state = state.copyWith(clearActiveCashier: true);
  }

  // Disassociates cashier selection entirely (returns to selection screen)
  Future<bool> switchCashier() async {
    if (state.isOffline) {
      // Swapping accounts is disabled when offline for POS security compliance
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    state = state.copyWith(clearActiveCashier: true, clearSelectedCashier: true);
    return true;
  }

  // Direct helper method to verify Admin override PINs dynamically
  Future<bool> authorizeAdminAction(String pin) async {
    final repo = ref.read(authRepositoryProvider);
    return repo.verifyAdminPin(pin);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
