import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import this

void main() async {
  // Mock SharedPreferences to avoid MissingPluginException
  SharedPreferences.setMockInitialValues({});
  
  print('--- VERIFYING SUPABASE CONNECTION (EMPIRICAL) ---');
  
  const url = 'https://inaxjdmofqbcoljxgnwr.supabase.co';
  const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImluYXhqZG1vZnFiY29sanhnbndyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ2ODM3MjcsImV4cCI6MjA4MDI1OTcyN30.zTcpvbRKcWJ4ecPKxgWUUvTaYC7wpB2s8SxFxE3IH8c';

  try {
    // 1. Initialize
    print('1. Initializing Supabase Client...');
    await Supabase.initialize(url: url, anonKey: anonKey);
    final client = Supabase.instance.client;
    print('   [SUCCESS] Client initialized.');

    // 2. Test Connection / Auth (Attempt Sign In with fake creds to check reachability)
    print('2. Testing Reachability (Sign In with garbage)...');
    try {
      await client.auth.signInWithPassword(email: 'test_connection@test.com', password: 'password');
    } on AuthException catch (e) {
      if (e.message == 'Invalid login credentials') {
        print('   [SUCCESS] Connected to Cloud DB (received expected "Invalid credentials" error).');
      } else {
        print('   [WARNING] Unexpected Auth Error: ${e.message}');
      }
    } catch (e) {
       print('   [ERROR] Connection Failed: $e');
       return;
    }

    // 3. Attempt to Create Test User (Dev Applicant)
    print('3. Attempting to Create Dev User (dev_applicant@gmail.com)...');
    // Changing domain from example.com to gmail.com to avoid potential blacklist
    final email = 'dev_applicant@gmail.com'; 
    final password = 'password';
    
    try {
      final response = await client.auth.signUp(
        email: email, 
        password: password,
        data: {'name': 'Dev Applicant'},
      );
      
      if (response.user != null) {
        print('   [SUCCESS] User Created! ID: ${response.user!.id}');
        print('   [INFO] User might need email confirmation depending on settings.');
      } else {
         print('   [?] SignUp returned no user (Check confirmation settings).');
      }
    } on AuthException catch (e) {
      if (e.message.contains('User already registered')) {
         print('   [SUCCESS] User already exists (Good!).');
      } else {
         print('   [ERROR] User Creation Failed: ${e.message}');
      }
    }

  } catch (e) {
    print('FATAL ERROR during verification: $e');
  }
}
