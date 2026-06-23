// core/network/supabase_service.dart
// Initializes Supabase connection and acts as a central access point

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  // PLACEHOLDERS: Replace these with your actual Supabase project credentials
  static const String supabaseUrl = 'https://ghkebnkzyixbcvufmsvw.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_r8LgGZ8TFhQm2ybO-wINJQ_hJCnNg65';

  bool _initialized = false;
  bool get isInitialized => _initialized;

  SupabaseClient get client {
    if (!_initialized) {
      throw StateError('Supabase is not initialized. Please configure valid credentials in supabase_service.dart.');
    }
    return Supabase.instance.client;
  }

  Future<void> init() async {
    if (supabaseUrl == 'https://YOUR_PROJECT_ID.supabase.co' || 
        supabaseAnonKey == 'YOUR_ANON_KEY' ||
        supabaseUrl.isEmpty || 
        supabaseAnonKey.isEmpty) {
      debugPrint('Supabase: Using placeholder credentials. Supabase sync will be offline-only.');
      _initialized = false;
      return;
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _initialized = true;
      debugPrint('Supabase: Initialized successfully.');
    } catch (e) {
      debugPrint('Supabase: Failed to initialize: $e');
      _initialized = false;
    }
  }
}
