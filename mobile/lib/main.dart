import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:mobile/core/router/router.dart';
import 'package:mobile/core/service_locator/app_config.dart';
import 'package:mobile/core/service_locator/app_config_provider.dart';
import 'package:mobile/core/providers/locale_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/core/theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════
// DEFAULT ENTRY POINT (DEV)
// ═══════════════════════════════════════════════════════════════════════════
void main() {
  final devConfig = AppConfig(
    appName: 'USA Visa Dev',
    flavor: Flavor.dev,
    apiBaseUrl: 'https://dev-api.usavpc.app',
    // Using REAL Cloud Credentials from .env.local
    supabaseUrl: 'https://inaxjdmofqbcoljxgnwr.supabase.co',
    supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImluYXhqZG1vZnFiY29sanhnbndyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ2ODM3MjcsImV4cCI6MjA4MDI1OTcyN30.zTcpvbRKcWJ4ecPKxgWUUvTaYC7wpB2s8SxFxE3IH8c',
    netlifyFunctionsUrl: 'https://usavpc.org',
  );

  mainCommon(devConfig);
}

Future<void> mainCommon(AppConfig config) async {
  // Initialize Bindings
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: config.supabaseUrl,
    anonKey: config.supabaseAnonKey,
  );

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
      ],
      child: MyApp(config: config),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final AppConfig config;

  const MyApp({super.key, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: config.appName,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      // i18n Configuration - Added 2026-01-21
      locale: locale,
      supportedLocales: LocaleNotifier.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == deviceLocale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
    );
  }
}
