enum Flavor { dev, prod }

class AppConfig {
  final String appName;
  final Flavor flavor;
  final String apiBaseUrl;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String netlifyFunctionsUrl; // Added

  AppConfig({
    required this.appName,
    required this.flavor,
    required this.apiBaseUrl,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.netlifyFunctionsUrl, // Added
  });
}
