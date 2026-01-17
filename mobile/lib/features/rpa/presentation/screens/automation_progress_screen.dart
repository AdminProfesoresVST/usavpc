import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:mobile/features/rpa/logic/script_injector.dart';
import 'package:mobile/features/rpa/presentation/providers/automation_provider.dart';
import 'package:mobile/features/rpa/presentation/widgets/hacking_mode_overlay.dart';

/// Production-ready DS-160 automation screen with WebView and JavaScript injection.
/// This screen loads the user's form data from Supabase and auto-fills the DS-160 form.
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
    // Load user data from Supabase
    Future.microtask(() {
      ref.read(automationProvider.notifier).loadUserData();
    });
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            ref.read(automationProvider.notifier).updateProgress(
              0.25,
              'Navegando a: ${_shortenUrl(url)}',
            );
          },
          onPageFinished: (String url) {
            setState(() => _isWebViewReady = true);
            ref.read(automationProvider.notifier).updateProgress(
              0.3,
              'Página cargada: ${_shortenUrl(url)}',
            );
            // Auto-inject when page loads and we have data
            _attemptAutoFill();
          },
          onWebResourceError: (WebResourceError error) {
            ref.read(automationProvider.notifier).recordError(
              'Error de red: ${error.description}',
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
    final state = ref.read(automationProvider);
    
    if (_hasInjected || state.formData == null || state.formData!.isEmpty) {
      return;
    }

    // Detect current page
    try {
      final pageInfoJson = await _webViewController.runJavaScriptReturningResult(
        _injector.generatePageDetectionScript(),
      );
      
      // Log page info for debugging
      debugPrint('Page info: $pageInfoJson');
      
      ref.read(automationProvider.notifier).updateProgress(
        0.4,
        'Detectando campos del formulario...',
      );

      // Small delay for page scripts to initialize
      await Future.delayed(const Duration(milliseconds: 500));

      // Execute batch fill
      ref.read(automationProvider.notifier).updateProgress(
        0.5,
        'Inyectando datos en formulario...',
      );

      final batchScript = _injector.generateBatchFillScript(state.formData!);
      final result = await _webViewController.runJavaScriptReturningResult(batchScript);

      // Parse results
      try {
        final resultStr = result.toString().replaceAll('"', '').replaceAll('\\', '');
        final results = jsonDecode(resultStr) as List;
        final filled = results.where((r) => r.toString().startsWith('FILLED') || r.toString().startsWith('SELECTED')).length;
        final notFound = results.where((r) => r.toString().startsWith('NOT_FOUND')).length;

        ref.read(automationProvider.notifier).updateProgress(
          0.8,
          'Campos llenados: $filled | No encontrados: $notFound',
        );
      } catch (_) {
        ref.read(automationProvider.notifier).updateProgress(
          0.8,
          'Inyección completada',
        );
      }

      setState(() => _hasInjected = true);

      ref.read(automationProvider.notifier).updateProgress(
        0.9,
        'Automatización lista. Revise los datos y continúe manualmente.',
      );

      ref.read(automationProvider.notifier).markComplete(
        'PROCESO COMPLETADO - Verifique los datos antes de continuar',
      );

    } catch (e) {
      ref.read(automationProvider.notifier).recordError(
        'Error durante inyección: $e',
      );
    }
  }

  void _manualInject() {
    setState(() => _hasInjected = false);
    _attemptAutoFill();
  }

  @override
  Widget build(BuildContext context) {
    final automationState = ref.watch(automationProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // WebView (main content)
          Positioned.fill(
            child: Column(
              children: [
                // Progress Header
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.greenAccent),
                            onPressed: () => context.pop(),
                          ),
                          const Text(
                            'DS-160 AUTO-FILL',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontFamily: 'Courier',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Spacer(),
                          if (automationState.formData != null && !_hasInjected)
                            TextButton(
                              onPressed: _manualInject,
                              child: const Text(
                                'INYECTAR',
                                style: TextStyle(color: Colors.greenAccent),
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
                      border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
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
                      color: Colors.black87,
                      border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '> CONSOLE OUTPUT',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontFamily: 'Courier',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
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
                                style: TextStyle(
                                  color: isError ? Colors.red : Colors.green.shade300,
                                  fontFamily: 'Courier',
                                  fontSize: 11,
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
          // Overlay when not ready
          if (!_isWebViewReady)
            const HackingModeOverlay(),
        ],
      ),
    );
  }
}
