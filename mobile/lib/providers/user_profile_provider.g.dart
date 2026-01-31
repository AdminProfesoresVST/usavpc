// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches user profile data from Supabase.
/// Returns a Map of profile fields for use by ConsularRisk analysis.

@ProviderFor(fetchUserProfile)
final fetchUserProfileProvider = FetchUserProfileProvider._();

/// Fetches user profile data from Supabase.
/// Returns a Map of profile fields for use by ConsularRisk analysis.

final class FetchUserProfileProvider extends $FunctionalProvider<
        AsyncValue<Map<String, dynamic>?>,
        Map<String, dynamic>?,
        FutureOr<Map<String, dynamic>?>>
    with
        $FutureModifier<Map<String, dynamic>?>,
        $FutureProvider<Map<String, dynamic>?> {
  /// Fetches user profile data from Supabase.
  /// Returns a Map of profile fields for use by ConsularRisk analysis.
  FetchUserProfileProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'fetchUserProfileProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$fetchUserProfileHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>?> create(Ref ref) {
    return fetchUserProfile(ref);
  }
}

String _$fetchUserProfileHash() => r'fc09c3f1791ce949cb9e84fcd6e539a66890a7b5';
