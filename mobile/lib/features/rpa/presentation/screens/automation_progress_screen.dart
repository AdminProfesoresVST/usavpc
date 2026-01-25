import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/features/rpa/logic/script_injector.dart';
import 'package:mobile/features/rpa/presentation/providers/automation_provider.dart';
import 'package:mobile/features/rpa/presentation/widgets/hacking_mode_overlay.dart';
import 'package:mobile/core/theme/app_theme.dart';

/// Production-ready DS-160 automation screen with full i18n support.
/// Updated: 2026-01-21 - Applied i18n per audit requirements
class AutomationProgressScreen extends ConsumerStatefulWidget {
  const AutomationProgressScreen({super.key});

  @override
  ConsumerState<AutomationProgressScreen> createState() => _AutomationProgressScreenState();
}

class _AutomationProgressScreenState extends ConsumerState<AutomationProgressScreen> {
  late WebViewController _webViewController;
  final ScriptInjector _injector = ScriptInjector();
  bool _isWebViewReady = false;
  bool _hasInjected = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    Future.microtask(() {
      ref.read(automationProvider.notifier).loadUserData();
    });
  }

  void _initializeWebView() {
    final l10n = context.l10n;
    
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            ref.read(automationProvider.notifier).updateProgress(
              0.25,
              '${l10n.navigatingTo}: ${_shortenUrl(url)}',
            );
          },
          onPageFinished: (String url) {
            setState(() => _isWebViewReady = true);
            ref.read(automationProvider.notifier).updateProgress(
              0.3,
              '${l10n.pageLoaded}: ${_shortenUrl(url)}',
            );
            _attemptAutoFill();
          },
          onWebResourceError: (WebResourceError error) {
            ref.read(automationProvider.notifier).recordError(
              '${l10n.networkError}: ${error.description}',
            );
          },
        ),
      )
      ..loadRequest(Uri.parse('https://ceac.state.gov/GenNIV/Default.aspx'));
  }

  String _shortenUrl(String url) {
    if (url.length > 50) {
      return '${url.substring(0, 50)}...';
    }
    return url;
  }

  Future<void> _attemptAutoFill() async {
    final l10n = context.l10n;
    final state = ref.read(automationProvider);
    
    if (_hasInjected || state.formData == null || state.formData!.isEmpty) {
      return;
    }

    try {
      final pageInfoJson = await _webViewController.runJavaScriptReturningResult(
        _injector.generatePageDetectionScript(),
      );
      
      debugPrint('Page info: $pageInfoJson');
      
      ref.read(automationProvider.notifier).updateProgress(
        0.4,
        l10n.detectingFormFields,
      );

      await Future.delayed(const Duration(milliseconds: 500));

      ref.read(automationProvider.notifier).updateProgress(
        0.5,
        l10n.injectingData,
      );

      final batchScript = _injector.generateBatchFillScript(state.formData!);
      final result = await _webViewController.runJavaScriptReturningResult(batchScript);

      try {
        final resultStr = result.toString().replaceAll('"', '').replaceAll('\\', '');
        final results = jsonDecode(resultStr) as List;
        final filled = results.where((r) => r.toString().startsWith('FILLED') || r.toString().startsWith('SELECTED')).length;
        final notFound = results.where((r) => r.toString().startsWith('NOT_FOUND')).length;

        ref.read(automationProvider.notifier).updateProgress(
          0.8,
          l10n.fieldsFilled(filled, notFound),
        );
      } catch (_) {
        ref.read(automationProvider.notifier).updateProgress(
          0.8,
          l10n.injectionComplete,
        );
      }

      setState(() => _hasInjected = true);

      ref.read(automationProvider.notifier).updateProgress(
        0.9,
        l10n.automationReady,
      );

      ref.read(automationProvider.notifier).markComplete(
        l10n.processComplete,
      );

    } catch (e) {
      ref.read(automationProvider.notifier).recordError(
        '${l10n.injectionError}: $e',
      );
    }
  }

  void _manualInject() {
    setState(() => _hasInjected = false);
    _attemptAutoFill();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final automationState = ref.watch(automationProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                // Progress Header
                Container(
                  color: AppTheme.navyPrimary,
                  padding: const EdgeInsetsDirectional.only(top: 50, start: 16, end: 16, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.greenAccent),
                            onPressed: () => context.pop(),
                          ),
                          Text(
                            l10n.ds160AutoFill,
                            style: AppTheme.h1WhiteBold,
                          ),
                          const Spacer(),
                          if (automationState.formData != null && !_hasInjected)
                            TextButton(
                              onPressed: _manualInject,
                              child: Text(
                                l10n.inject,
                                style: AppTheme.bodyWhiteRegular,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: automationState.progress,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          automationState.error != null ? Colors.red : Colors.greenAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                // WebView
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
                      borderRadius: AppTheme.smallRadius,
                    ),
                    child: ClipRRect(
                      borderRadius: AppTheme.smallRadius,
                      child: WebViewWidget(controller: _webViewController),
                    ),
                  ),
                ),
                // Log Console
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.navyPrimary,
                      border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
                      borderRadius: AppTheme.smallRadius,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.consoleOutput,
                          style: AppTheme.captionWhiteBold,
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: ListView.builder(
                            reverse: true,
                            itemCount: automationState.logs.length,
                            itemBuilder: (context, index) {
                              final log = automationState.logs[automationState.logs.length - 1 - index];
                              final isError = log.contains('ERROR');
                              return Text(
                                log,
                                style: AppTheme.captionWhiteRegular.copyWith(
                                  color: isError ? Colors.red : Colors.green.shade300,
                                  fontFamily: 'Courier',
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!_isWebViewReady)
            const HackingModeOverlay(),
        ],
      ),
    );
  }
}
