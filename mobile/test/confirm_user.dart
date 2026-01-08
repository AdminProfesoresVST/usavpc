import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Mock SharedPreferences
  SharedPreferences.setMockInitialValues({});
  
  // print('--- FORCING EMAIL CONFIRMATION (ADMIN) ---');
  
  const url = 'https://inaxjdmofqbcoljxgnwr.supabase.co';
  // SERVICE ROLE KEY from .env.local
  const serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImluYXhqZG1vZnFiY29sanhnbndyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDY4MzcyNywiZXhwIjoyMDgwMjU5NzI3fQ.4gnwqnTDSqhwjcsRCTiqdYQOiLutJGRMXWhKFVoP2WM';

  try {
    // Initialize standard client (to access admin? No, usually need explicit SupabaseClient for admin in Dart)
    // Supabase.initialize is for the Singleton. Let's make a raw client.
    final client = SupabaseClient(url, serviceRoleKey);
    
    // print('1. Client initialized with Service Role Key.');
    
    // The user ID from previous run was: e93badc1-d62c-48aa-a396-eeec79fc1473
    // Or we can find by email if we list users? But listUsers might be paginated.
    // Let's try to just update the specific user ID we know, or sign up again with admin privileges?
    
    // Easier: Delete the user and re-create with email_confirm: true using admin API?
    // Or just update.
    
    final userId = 'e93badc1-d62c-48aa-a396-eeec79fc1473';
    
    // print('2. Updating user $userId to valid email_confirmed_at...');
    
    final response = await client.auth.admin.updateUserById(
      userId,
      attributes: AdminUserAttributes(
        emailConfirm: true,
        userMetadata: {'name': 'Dev Applicant Verified'}
      ),
    );
    
    if (response.user != null) {
       // print('   [SUCCESS] User Email Confirmed! Payload: ${response.user!.emailConfirmedAt}');
    } else {
       // print('   [ERROR] No user returned from update.');
    }

  } catch (e) {
    // print('FATAL ERROR: $e');
  }
}
