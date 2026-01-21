// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider del locale actual de la aplicación.
/// Controla el idioma de la app y persiste la preferencia del usuario.
/// Added: 2026-01-21 - Implements dynamic language switching per multilingual-architect skill

@ProviderFor(LocaleNotifier)
const localeProvider = LocaleNotifierProvider._();

/// Provider del locale actual de la aplicación.
/// Controla el idioma de la app y persiste la preferencia del usuario.
/// Added: 2026-01-21 - Implements dynamic language switching per multilingual-architect skill
final class LocaleNotifierProvider
    extends $NotifierProvider<LocaleNotifier, Locale> {
  /// Provider del locale actual de la aplicación.
  /// Controla el idioma de la app y persiste la preferencia del usuario.
  /// Added: 2026-01-21 - Implements dynamic language switching per multilingual-architect skill
  const LocaleNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'localeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$localeNotifierHash();

  @$internal
  @override
  LocaleNotifier create() => LocaleNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale>(value),
    );
  }
}

String _$localeNotifierHash() => r'bfa9a2ad6c48d793bcf523ee463c941ccf1e36c9';

/// Provider del locale actual de la aplicación.
/// Controla el idioma de la app y persiste la preferencia del usuario.
/// Added: 2026-01-21 - Implements dynamic language switching per multilingual-architect skill

abstract class _$LocaleNotifier extends $Notifier<Locale> {
  Locale build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Locale, Locale>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Locale, Locale>, Locale, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
