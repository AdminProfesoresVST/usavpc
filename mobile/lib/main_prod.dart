import 'package:mobile/core/service_locator/app_config.dart';
import 'package:mobile/main.dart';

void main() {
  final prodConfig = AppConfig(
    appName: 'USA Visa Center',
    flavor: Flavor.prod,
    apiBaseUrl: 'https://usavpc.org',
    // Production Supabase credentials
    supabaseUrl: 'https://inaxjdmofqbcoljxgnwr.supabase.co',
    supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImluYXhqZG1vZnFiY29sanhnbndyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ2ODM3MjcsImV4cCI6MjA4MDI1OTcyN30.zTcpvbRKcWJ4ecPKxgWUUvTaYC7wpB2s8SxFxE3IH8c',
    netlifyFunctionsUrl: 'https://usavpc.org/.netlify/functions',
  );

  mainCommon(prodConfig);
}
