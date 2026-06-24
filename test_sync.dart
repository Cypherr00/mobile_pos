import 'package:supabase/supabase.dart';
import 'dart:io';

// We must manually initialize the Supabase client for a dart script
Future<void> main() async {
  final url = 'https://ghkebnkzyixbcvufmsvw.supabase.co';
  final anonKey = 'sb_publishable_r8LgGZ8TFhQm2ybO-wINJQ_hJCnNg65';

  print('Initializing Supabase...');
  final supabase = SupabaseClient(url, anonKey);

  print('Attempting to sign in as davenjerthlozada@gmail.com...');
  try {
    final authRes = await supabase.auth.signInWithPassword(
      email: 'davenjerthlozada@gmail.com',
      password: '000000',
    );
    print('✅ Signed in successfully. User ID: ${authRes.user?.id}');
  } catch (e) {
    print('❌ Sign-in failed: $e');
    exit(1);
  }

  print('Testing SELECT on public.products...');
  try {
    final data = await supabase.from('products').select().limit(5);
    print('✅ SELECT succeeded. Found ${data.length} products.');
  } catch (e) {
    print('❌ SELECT failed: $e');
  }

  print('Testing UPSERT on public.products...');
  try {
    await supabase.from('products').upsert({
      'id': 'test-id-1234',
      'name': 'Test Debug Item',
      'price_cents': 100,
      'is_deleted': false,
      'version': 1,
    });
    print('✅ UPSERT succeeded.');
    
    // Clean up
    await supabase.from('products').delete().eq('id', 'test-id-1234');
    print('✅ Cleanup succeeded.');
  } catch (e) {
    print('❌ UPSERT failed: $e');
  }

  exit(0);
}
