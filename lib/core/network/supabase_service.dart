// core/network/supabase_service.dart
// Initializes Supabase connection and acts as a central access point

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  bool _initialized = false;
  bool get isInitialized => _initialized;
  String? initError; // Capture the error message

  SupabaseClient get client {
    if (!_initialized) {
      throw StateError('Supabase is not initialized. Please configure valid credentials in supabase_config.dart.');
    }
    return Supabase.instance.client;
  }

  Future<void> init() async {
    if (SupabaseConfig.url.isEmpty ||
        SupabaseConfig.publishableKey.isEmpty) {
      initError = 'Missing URL or publishable key in config.';
      debugPrint('Supabase: Missing credentials in supabase_config.dart. Running in offline-only mode.');
      _initialized = false;
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.publishableKey,
      );

      // Auto sign-in as service account to pass RLS policies
      await Supabase.instance.client.auth.signInWithPassword(
        email: SupabaseConfig.serviceEmail,
        password: SupabaseConfig.servicePassword,
      );

      _initialized = true;
      initError = null;
      debugPrint('Supabase: Initialized successfully with background auth.');
    } catch (e) {
      initError = e.toString();
      debugPrint('Supabase: Failed to initialize/auth: $e');
      _initialized = false;
    }
  }
}
