import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile_pos/core/network/supabase_service.dart';

void main() {
  test('Debug Supabase Connection and Schema State', () async {
    print('=== DIAGNOSTIC REPORT START ===');
    print('Supabase Project URL: ${SupabaseService.supabaseUrl}');
    print('Supabase Anon Key: ${SupabaseService.supabaseAnonKey.substring(0, 15)}...');

    try {
      // Create a direct client to bypass Flutter binding restrictions during CLI tests
      final client = SupabaseClient(
        SupabaseService.supabaseUrl,
        SupabaseService.supabaseAnonKey,
      );

      print('Attempting to connect to cashiers table...');
      final cashiers = await client.from('cashiers').select();
      print('CONNECTION SUCCESSFUL!');
      print('Found ${cashiers.length} cashier records:');
      
      for (final cashier in cashiers) {
        print('  - ID: ${cashier['id']}');
        print('    Name: ${cashier['name']}');
        print('    Role: ${cashier['role']}');
        print('    Is Active: ${cashier['is_active']}');
        print('    Hash in DB: ${cashier['pin_hash']}');
      }

      print('Attempting to query products table...');
      final products = await client.from('products').select();
      print('Products count in Supabase: ${products.length}');

    } catch (e, stack) {
      print('CONNECTION FAILED!');
      print('Error Type: ${e.runtimeType}');
      print('Error Message: $e');
      print('Stacktrace:\n$stack');
    }
    print('=== DIAGNOSTIC REPORT END ===');
  });
}
