// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'help_center_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(faqs)
final faqsProvider = FaqsProvider._();

final class FaqsProvider extends $FunctionalProvider<AsyncValue<List<Faq>>,
        List<Faq>, FutureOr<List<Faq>>>
    with $FutureModifier<List<Faq>>, $FutureProvider<List<Faq>> {
  FaqsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'faqsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$faqsHash();

  @$internal
  @override
  $FutureProviderElement<List<Faq>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Faq>> create(Ref ref) {
    return faqs(ref);
  }
}

String _$faqsHash() => r'41258f93b54ca4756ec89c06fda1843b4017997a';
