import 'package:mobile/core/service_locator/app_config.dart';
import 'package:mobile/main.dart';

void main() {
  final prodConfig = AppConfig(
    appName: 'USA Visa Center',
    flavor: Flavor.prod,
    apiBaseUrl: 'https://api.usavpc.app',
    supabaseUrl: 'https://your-prod-supabase.co',
    supabaseAnonKey: 'your-prod-key',
    netlifyFunctionsUrl: 'https://api.usavpc.app/.netlify/functions',
  );

  mainCommon(prodConfig);
}
