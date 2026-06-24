// providers/sync_provider.dart
// Riverpod state provider for data synchronization status

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/sync/sync_engine.dart';
import '../core/network/supabase_service.dart';

class SyncState {
  final bool isSyncing;
  final String? errorMessage;
  final String? lastSyncTime;

  SyncState({
    this.isSyncing = false,
    this.errorMessage,
    this.lastSyncTime,
  });

  SyncState copyWith({
    bool? isSyncing,
    String? errorMessage,
    String? lastSyncTime,
    bool clearError = false,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

class SyncNotifier extends Notifier<SyncState> {
  @override
  SyncState build() => SyncState();

  Future<void> sync() async {
    if (!SupabaseService.instance.isInitialized) {
      final error = SupabaseService.instance.initError ?? 'Supabase credentials are not configured.';
      state = state.copyWith(errorMessage: 'Connection Failed: $error');
      return;
    }
    
    state = state.copyWith(isSyncing: true, clearError: true);
    try {
      await SyncEngine.instance.syncAll();
      state = state.copyWith(
        isSyncing: false,
        lastSyncTime: DateTime.now().toLocal().toString().split('.').first,
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        errorMessage: e.toString(),
      );
    }
  }
}

final syncProvider = NotifierProvider<SyncNotifier, SyncState>(
  SyncNotifier.new,
);
