import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/network/supabase_client.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_header.dart';
import 'package:mobile/core/widgets/app_toast.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // FIXED: Added missing import
import 'package:mobile/services/ai/smart_interview_agent.dart';
import 'package:mobile/services/ai_repository.dart';
import 'package:mobile/services/voice_manager.dart'; // Import VoiceManager
import 'package:mobile/core/widgets/premium_chat_input.dart';

/// AI-powered chat intake with full i18n support.
class Ds160IntakeScreen extends ConsumerStatefulWidget {
  const Ds160IntakeScreen({super.key});

  @override
  ConsumerState<Ds160IntakeScreen> createState() => _Ds160IntakeScreenState();
}

class _Ds160IntakeScreenState extends ConsumerState<Ds160IntakeScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  final Map<String, dynamic> _formData = {};
  bool _isLoading = true;
  bool _isSending = false;

  // IAMI: Intelligent Migration Assistant Mode
  bool _useIAMI = true; // Default to IAMI
  IAMISuggestion? _pendingSuggestion; // For consent flow

  // SMART SKIP: Aliases to map DB keys to OCR keys
  final Map<String, String> _knownAliases = {
    'last_name': 'surname',
    'first_name': 'given_name',
    'dob': 'birth_date',
    'passport_num': 'passport_number',
    'nationality': 'nationality', 
    'gender': 'sex',
    // Robust mappings for missing fields
    'native_alphabet': 'native_alphabet_name',
    'native_name': 'native_alphabet_name',
    'telecode': 'telecode_name',
    'other_names_used': 'other_names', 
    'other_names_list': 'other_names', // If list depends on the same key

    // SCHEMA COMPATIBILITY MAPPINGS (Critical Fix)
    'ds160_data.personal.native_name': 'native_name',
    'ds160_data.personal.telecode_name': 'telecode_name',
    'ds160_data.personal.other_names_used': 'other_names_used',
    'ds160_data.personal.other_names_list': 'other_names_list',
    'native_name': 'native_alphabet_name', // Double alias
    'telecode_name': 'telecode', // Double alias
  };

  // SMART SKIP: Keys that must ALWAYS be skipped if they exist in FormData
  final Set<String> _alwaysSkipKeys = {
    'surname', 'given_name', 'birth_date', 'passport_number', 'nationality', 'sex',
    'last_name', 'first_name', 'dob', 'passport_num', 'gender',
    'native_alphabet_name', 'native_alphabet', 'native_name',
    'telecode_name', 'telecode', 'telecode_status',
    'ds160_data.personal.native_name', 'ds160_data.personal.telecode_name', // Include Schema Keys
    'other_names_used', 'other_names', 'ds160_data.personal.other_names_used'
  };

  // SMART SKIP: Nationalities that use Latin alphabet (Verification V2)
  final Set<String> _latinNationalities = {
    'MEX', 'DOM', 'COL', 'ARG', 'PER', 'VEN', 'CHL', 'ECU', 'GTM', 'CUB', 'ESP', 'USA', 'CAN', 
    'GBR', 'FRA', 'DEU', 'ITA', 'BRA', 'PRT', 'HND', 'SLV', 'PAN', 'CRI', 'URY', 'PRY', 'BOL',
    'DOMINICAN REPUBLIC', 'MEXICO', 'COLOMBIA' // Add full names just in case
  };

  // DEBUG STATS
  int _debugFetched = -1;
  int _debugFiltered = -1;
  String _debugError = '';

  bool _isInit = true;

  // VOICE
  final VoiceManager _voiceManager = VoiceManager();
  bool _isListening = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _initIAMI(); // Use IAMI instead of local logic
      _voiceManager.initialize();
      _isInit = false;
    }
  }

  /// IAMI: Initialize conversation with intelligent greeting
  Future<void> _initIAMI() async {
    setState(() => _isLoading = true);
    
    try {
      final aiRepo = ref.read(aiRepositoryProvider);
      
      // First call with null message to get greeting + acknowledge existing data
      final response = await aiRepo.sendIntakeMessage(
        message: null,
        formType: 'DS-160',
        existingData: _formData,
      );
      
      // Display IAMI's greeting
      _addBotMessage(response.message);
      
      // Log skipped fields for debugging
      if (response.skippedFields != null && response.skippedFields!.isNotEmpty) {
        debugPrint('[IAMI] Skipped fields: ${response.skippedFields}');
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('[IAMI] Init Error: $e');
      // Fallback to legacy local logic if IAMI fails
      _loadQuestions();
    }
  }

  Future<void> _loadQuestions() async {
    try {
      // 0. READ QUERY PARAMS (Immediate Cache)
      final state = GoRouterState.of(context);
      final params = state.uri.queryParameters;
      
      // FIXED: DS-160 ONLY. No dynamic table switching.
      const tableName = 'ds160_questions';
      
      if (params.isNotEmpty) {
        // Map param keys to DB keys
        if (params['surname'] != null) _formData['surname'] = params['surname'];
        if (params['given_name'] != null) _formData['given_name'] = params['given_name'];
        if (params['dob'] != null) _formData['birth_date'] = params['dob'];
        if (params['nationality'] != null) _formData['nationality'] = params['nationality'];
        if (params['passport'] != null) _formData['passport_number'] = params['passport'];
        if (params['sex'] != null) _formData['sex'] = params['sex'];
      }

      final supabase = ref.read(supabaseClientProvider);
      
      final userId = supabase.auth.currentUser?.id;
      
      List<dynamic> rawQuestions = [];
      Map<String, dynamic>? appData;
      Map<String, dynamic>? profileData;

      if (userId != null) {
        // PARALLEL FETCH: App Data, Profile Context, and Questions
        final responses = await Future.wait([
          supabase.from('applications').select('form_data').eq('user_id', userId).maybeSingle(),
          supabase.from('profiles').select().eq('id', userId).maybeSingle(),
          supabase.from(tableName).select().order('section').order('section_order'),
        ]);

        appData = responses[0] as Map<String, dynamic>?;
        profileData = responses[1] as Map<String, dynamic>?;
        rawQuestions = responses[2] as List<dynamic>;
      } else {
        // Fallback for anonymous (unlikely)
         rawQuestions = await supabase
          .from(tableName)
          .select()
          .order('section')
          .order('section_order');
      }

      // 1. Hydrate Form Data from Application
      if (appData != null && appData['form_data'] != null) {
        final dbData = Map<String, dynamic>.from(appData['form_data']);
        _formData.addAll(dbData);
      }

      // 2. Hydrate from Profile (if missing in App) - CRITICAL FOR NATIVE ALPHABET SKIP
      if (_formData['nationality'] == null && profileData != null) {
         // Try to find nationality in profile fields
         // Note: profiles table might have 'country' or 'citizenship' depending on schema evolution
         final profileNat = profileData['nationality'] ?? profileData['citizenship'] ?? profileData['country'];
         if (profileNat != null) {
           _formData['nationality'] = profileNat.toString().toUpperCase();
         }
      }

      // 3. Ensure Latin Logic Triggers (Verification V2)
      String nat = _formData['nationality']?.toString().toUpperCase() ?? '';
      
      // Heuristic normalization
      if (nat.contains('DOMINICA')) nat = 'DOM';
      else if (nat.contains('MEXIC')) nat = 'MEX';
      else if (nat.contains('ARGENT')) nat = 'ARG';
      else if (nat.contains('COLOMB')) nat = 'COL';
      
      final isLatin = _latinNationalities.contains(nat) || _latinNationalities.contains(_formData['nationality']); // 3. Smart Skip - Nationality Logic
      _applyNationalitySkips(isLatin);

      // 4. SMART AGENT: Pre-process existing data (Passport)
      // If we have passport data in raw form, normalize it now so the bot sees it.
      // This solves "Why is it asking for my name if I scanned it?"
      if (_formData.isNotEmpty) {
          // Attempt to normalize any passport-like keys
          if (_formData['passport_number'] != null || _formData['document_number'] != null) {
              // Creating a pseudo-model to re-inject standard keys
               final passportContext = {
                  'passport_number': _formData['passport_number'] ?? _formData['document_number'],
                  'surname': _formData['surname'] ?? _formData['last_name'],
                  'given_name': _formData['given_name'] ?? _formData['first_name'],
                  'nationality': nat,
                  'birth_date': _formData['birth_date'] ?? _formData['dob'],
               };
               _formData.addAll(passportContext); // Ensure standard keys are set
          }
      }
 
      final totalFetched = (rawQuestions as List).length;

      if (totalFetched == 0) {
        _debugError = 'Error: No questions found in DS-160';
        setState(() => _isLoading = false);
        return;
      }
      
      // CAST to List<Map> for manipulation
      var questionsList = rawQuestions.toList().cast<Map<String, dynamic>>();

      // CONTEXT RECOVERY: If Nationality is missing, ASK IT FIRST!
      // This solves the "Native Alphabet" loop for fresh users.
      if (_formData['nationality'] == null) {
          final natIndex = questionsList.indexWhere((q) => q['field_key'] == 'nationality');
          if (natIndex != -1) {
            final natQ = questionsList.removeAt(natIndex);
            questionsList.insert(0, natQ); // Move to TOP
            
             // Also move "Country of Origin" if it exists, to keep flow natural?
             // No, Nationality is the critical dependency for skipping.
          }
      }

      // DS-160 Section Order
      final sectionOrder = {
        'personal': 1,
        'address': 2,
        'passport': 3,
        'travel': 4,
        'family': 5,
        'work': 6,
        'security': 7,
      };

      questionsList.sort((a, b) {
        final secA = a['section'] as String? ?? '';
        final secB = b['section'] as String? ?? '';
        
        final orderA = sectionOrder[secA] ?? 99;
        final orderB = sectionOrder[secB] ?? 99;
        
        if (orderA != orderB) return orderA.compareTo(orderB);
        
        final secOrderA = a['section_order'] as int? ?? 0;
        final secOrderB = b['section_order'] as int? ?? 0;
        
        return secOrderA.compareTo(secOrderB);
      });

      // Filter Logic
      final filteredQuestions = questionsList.where((q) {
        // 1. Check "skip_if_exists" (Smart Skip)
        final key = q['field_key']; // FIX: Use field_key (string), not id (UUID)
        if (_alwaysSkipKeys.contains(key) && _formData.containsKey(key)) {
            // Special check: don't skip if the value is null/empty
             final val = _formData[key];
             if (val != null && val.toString().isNotEmpty) {
                 return false;
             }
        }

        // 2. Check "skip_if_ocr"
        if (q['skip_if_ocr'] == true) {
             // If field is in _knownAliases keys (e.g. 'surname', 'dob') AND we have data
             if (_formData.containsKey(key) && _formData[key] != null) {
               return false;
             }
        }

        // 3. Dependency Check (CASE INSENSITIVE FIX)
        if (q['depends_on'] != null && q['depends_on_value'] != null) {
          final dependKey = q['depends_on'];
          final dependAlias = _knownAliases[dependKey] ?? dependKey;
          var dependValue = _formData[dependKey] ?? _formData[dependAlias]; 

          // Fallback check for schema keys
          if (dependValue == null && dependKey.startsWith('ds160_data')) {
             // Try to find the short key version in formData
             final shortKey = dependKey.split('.').last;
             dependValue = _formData[shortKey];
          }

          // SMART AGENT LOGIC (Phase 1)
          final requiredVal = q['depends_on_value'].toString();
          final actualVal = dependValue?.toString();

          if (!SmartInterviewAgent.evaluateLogic(actualVal, requiredVal)) {
            return false;
          }
        }
        return true;
      }).toList().cast<Map<String, dynamic>>();


      _debugFetched = totalFetched;
      _debugFiltered = filteredQuestions.length;

      // FORCE RAW if filter is too aggressive
      if (filteredQuestions.isEmpty && totalFetched > 0) {
         _questions = rawQuestions.toList().cast<Map<String, dynamic>>();
      } else {
         _questions = filteredQuestions;
      }

      // NO HARDCODED FALLBACKS ALLOWED
      if (_questions.isEmpty) {
         _debugError = 'DB returned 0 questions (Raw=$totalFetched)';

         if (mounted) {
            AppToast.show(context, context.l10n.errorNoQuestionsAvailable, isError: true);
         }
         setState(() => _isLoading = false);
         return;
      }
      

      setState(() => _isLoading = false);
      _askNextQuestion();
    } catch (e) {
      if (e is PostgrestException) {
         _debugError = 'PG Error: ${e.message} (Code: ${e.code})\nDetails: ${e.details}';
      } else {
         _debugError = e.toString();
      }

      if (mounted) {
        setState(() => _isLoading = false);
        // Error is now safely displayed in the Debug Overlay
      }
    }
  }

  // Removed _seedDefaultQuestions (User confirmed data exists)

  void _addBotMessage(String text, {List<String>? tips, String? example}) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        tips: tips,
        example: example,
      ));
    });
    _scrollToBottom();
    _voiceManager.speak(text); // Speak the question
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _applyNationalitySkips([bool? forceLatin]) {
      String nat = _formData['nationality']?.toString().toUpperCase() ?? '';
      
      // ROBUST MATCHING: Check strictly codes OR substring matches for common Latin inputs
      bool matchCode = ['DOM', 'MEX', 'COL', 'ESP', 'ARG', 'PER', 'CHL', 'VEN', 'PAN', 'CRI'].contains(nat);
      bool matchFuzzy = nat.contains('DOMINI') || 
                        nat.contains('MEXIC') || 
                        nat.contains('COLOMB') || 
                        nat.contains('VENEZ') || 
                        nat.contains('ARGENT') || 
                        nat.contains('PANAM') ||
                        nat.contains('PERU') ||
                        nat.contains('CHIL') ||
                        nat.contains('COSTA RICA') ||
                        nat.contains('SANTO DOMINGO'); // Specific fix for user behavior

      bool isLatin = forceLatin ?? (matchCode || matchFuzzy);
      
      if (isLatin) {
         // NUCLEAR INJECTION: Set ALL variants to ensures usage
         _formData['native_alphabet_name'] = 'Does Not Apply'; 
         _formData['native_alphabet'] = 'Does Not Apply';
         _formData['native_name'] = 'Does Not Apply';

         _formData['telecode_name'] = 'No';
         _formData['telecode'] = 'No';
         _formData['telecode_status'] = 'No';
         
         // INJECT SCHEMA KEYS TOO
         _formData['ds160_data.personal.native_name'] = 'Does Not Apply';
         _formData['ds160_data.personal.telecode_name'] = 'No';
         _formData['full_name_native'] = 'Does Not Apply'; // CRITICAL: Matches DB field_key
      }
  }

  void _askNextQuestion() {
    try {
      if (_currentQuestionIndex >= _questions.length) {
        _completeIntake();
        return;
      }

      final question = _questions[_currentQuestionIndex];
      // Robust casting with fallbacks
      final tipsList = question['tips'] as List?;
      final tips = tipsList?.map((e) => e.toString()).toList() ?? <String>[];
      final example = question['example_good']?.toString();
      final questionText = question['question_friendly']?.toString() ?? context.l10n.errorMissingQuestionText;
      
      _addBotMessage(questionText, tips: tips, example: example);
    } catch (e) {
      if (mounted) {
         AppToast.show(context, 'Error displaying question: $e', isError: true);
      }
      setState(() => _debugError = 'AskNext Crash: $e');
    }
  }

  /// IAMI: Handle send via Intelligent Migration Assistant API
  Future<void> _handleSendIAMI() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _addUserMessage(text);
    _controller.clear();
    setState(() => _isSending = true);

    try {
      final aiRepo = ref.read(aiRepositoryProvider);
      
      final response = await aiRepo.sendIntakeMessage(
        message: text,
        formType: 'DS-160',
        existingData: _formData,
      );

      // Handle Suggestion Flow (Proactive Refinement with Consent)
      if (response.requiresConsent && response.suggestion != null) {
        setState(() => _pendingSuggestion = response.suggestion);
        _showSuggestionDialog(response.suggestion!, response.message);
      } else {
        // Normal flow: display the AI's message
        _addBotMessage(response.message);

        // Update local form data if next step provides field info
        if (response.nextStep != null && response.nextStep!['field'] != null) {
          final field = response.nextStep!['field'] as String;
          // Save the user's answer to local state
          _formData[field] = text;
        }
      }
    } catch (e) {
      debugPrint('[IAMI] Send Error: $e');
      _addBotMessage('Error procesando tu respuesta. Por favor intenta de nuevo.');
    } finally {
      setState(() => _isSending = false);
    }
  }

  /// IAMI: Show suggestion dialog for user consent
  void _showSuggestionDialog(IAMISuggestion suggestion, String aiMessage) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.navyPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('💡 Sugerencia de Mejora', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(aiMessage, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.navyPrimary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tu respuesta:', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  Text('"${suggestion.original}"', style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('Sugerencia mejorada:', style: TextStyle(color: AppTheme.accentGold, fontSize: 12)),
                  Text('"${suggestion.improved}"', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('📌 ${suggestion.reason}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _addBotMessage('Entendido, usaremos tu respuesta original.');
              setState(() => _pendingSuggestion = null);
            },
            child: const Text('Mantener Original', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGold),
            onPressed: () {
              Navigator.pop(ctx);
              _addBotMessage('Perfecto, he guardado la versión mejorada. ✅');
              // TODO: Call backend to confirm save with improved version
              setState(() => _pendingSuggestion = null);
            },
            child: Text('Aceptar Mejora', style: TextStyle(color: AppTheme.navyPrimary)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSend() async {

    if (_isSending) return;
    
    // IAMI Mode: Use intelligent API instead of local logic
    if (_useIAMI) {
      await _handleSendIAMI();
      return;
    }
    
    // LEGACY: Guard for local question flow
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) {

       _completeIntake();
       return;
    }

    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _addUserMessage(text);
    _controller.clear();
    setState(() => _isSending = true);

    try {
      final question = _questions[_currentQuestionIndex];
      final fieldKey = question['field_key'] as String;


      // ... regex validation ...

      // SMART AGENT VALIDATION (Phase 2)
      final validationError = SmartInterviewAgent.validateAnswer(fieldKey, text);
      if (validationError != null) {
          _addBotMessage(validationError);
          setState(() => _isSending = false);
          return;
      }

      _formData[fieldKey] = text;
      
      final supabase = ref.read(supabaseClientProvider);
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {

        // Manual upsert logic to avoid 42P10 (No unique constraint)
        final existing = await supabase
            .from('applications')
            .select('id')
            .eq('user_id', userId)
            .maybeSingle();

        final dataToSave = {
          'user_id': userId,
          'form_data': _formData,
        };

        if (existing != null) {
          await supabase
              .from('applications')
              .update(dataToSave)
              .eq('id', existing['id']);
        } else {
          await supabase
              .from('applications')
              .insert(dataToSave);
        }

      }

      _currentQuestionIndex++;
      
      // RE-APPLY SKIPS: If nationality changed, update nuclear overrides
      if (fieldKey == 'nationality') {
         _applyNationalitySkips();
      }

      // AUTO-SKIP mechanism for runtime changes
      while (_currentQuestionIndex < _questions.length) {
          final nextQ = _questions[_currentQuestionIndex];
          final nextKey = nextQ['field_key'] as String;
          // Check key AND potential aliases (e.g. if list uses full_name_native but we set native_name)
          final nextAlias = _knownAliases[nextKey] ?? nextKey;
          
          final hasData = _formData.containsKey(nextKey) || _formData.containsKey(nextAlias);
          final val = _formData[nextKey] ?? _formData[nextAlias];

          if (hasData && val != null && val.toString().isNotEmpty) {
              _currentQuestionIndex++;
          } else {
             break;
          }
      }

      _askNextQuestion();
    } catch (e) {

       if (mounted) _addBotMessage(context.l10n.savingError(e.toString()));
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _completeIntake() {
    _addBotMessage(context.l10n.intakeComplete);
    
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: '',
            isUser: false,
            isAction: true,
          ));
        });
        _scrollToBottom();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final totalQuestions = _questions.length;
    final answeredQuestions = _currentQuestionIndex;
    final progress = totalQuestions > 0 ? answeredQuestions / totalQuestions : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppHeaderWithProgress(

        title: 'DS-160 INTAKE',  // EXTREMELY CLEAR NAMING
        subtitle: totalQuestions > 0 
            ? l10n.questionProgress(answeredQuestions + 1, totalQuestions)
            : null,
        progress: progress,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // PREMIUM SPACER (Replaces Debug Dashboard)
                SizedBox(height: AppTheme.espacioEntreSecciones),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: AppTheme.paddingEstandar,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) => _ChatBubble(
                      message: _messages[index],
                      onAction: () => context.push('/dashboard'),
                      onReplay: () => _voiceManager.speak(_messages[index].text),
                    ),
                  ),
                ),
                if (!_isLoading && _messages.isEmpty)
                  Center(
                    child: Container(
                      padding: AppTheme.paddingGrande,
                      margin: AppTheme.paddingGrande,
                      decoration: BoxDecoration(
                        color: AppTheme.warningOrange.withValues(alpha: 0.1),
                        border: Border.all(color: AppTheme.warningOrange),
                        borderRadius: AppTheme.cardRadius,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bug_report, size: 48, color: AppTheme.warningOrange),
                          Text('DEBUG MODE: No Messages', style: AppTheme.h2NavyBold),
                          Divider(),
                          Text('Fetched: $_debugFetched'),
                          Text('Filtered: $_debugFiltered'),
                          Text('Keys: ${_formData.keys.length}'),
                          Text('Keys List: ${_formData.keys.join(", ")}'),
                          if (_debugError.isNotEmpty) 
                            Text('Error: $_debugError', style: TextStyle(color: Colors.red)),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                               setState(() {
                                 _formData.clear(); // Nuclear Reset
                                 _loadQuestions();
                               });
                            },
                            child: Text('RESET FORM DATA'), // Emergency Hatch
                          )
                        ],
                      ),
                    ),
                  ),
                _buildInputArea(l10n),
              ],
            ),
    );
  }

  Widget _buildInputArea(dynamic l10n) {
    return PremiumChatInput(
      controller: _controller,
      onSend: _handleSend,
      onToggleListening: _toggleListening,
      isSending: _isSending,
      isListening: _isListening,
    );
  }

  void _toggleListening() {
    if (_isListening) {
      _voiceManager.stopListening();
      setState(() => _isListening = false);
    } else {
      _voiceManager.startListening(
        onResult: (text) {
          setState(() {
            _controller.text = text;
            _controller.selection = TextSelection.fromPosition(TextPosition(offset: text.length));
          });
        },
        onListeningStateChanged: (listening) {
          setState(() => _isListening = listening);
        },
      );
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final List<String>? tips;
  final String? example;
  final bool isAction;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.tips,
    this.example,
    this.isAction = false,
  });
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onAction;

  final VoidCallback? onReplay;

  const _ChatBubble({required this.message, this.onAction, this.onReplay});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    if (message.isAction) {
      return Padding(
        padding: AppTheme.paddingVertical,
        child: ElevatedButton(
          onPressed: onAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.navyPrimary,
            padding: AppTheme.paddingPantalla,
            shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius),
          ),
          child: Text(l10n.viewMyApplication, style: AppTheme.h2NavyBold.copyWith(color: AppTheme.inkInverse)),
        ),
      );
    }

    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          
          // Replay UI
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
               if (!isUser) ...[
                 IconButton(
                   icon: const Icon(Icons.volume_up_rounded, size: 20, color: AppTheme.navyPrimary),
                   onPressed: onReplay,
                   tooltip: 'Repetir audio',
                 ),
                 const SizedBox(width: 4),
               ],
               Container(
                margin: const EdgeInsetsDirectional.only(bottom: AppTheme.espacioEntreLabelInput),
                padding: AppTheme.paddingCampo,
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.70), // Reduced width to fit icon
                decoration: BoxDecoration(
                  color: isUser ? AppTheme.navyPrimary : AppTheme.inkInverse,
                  borderRadius: BorderRadius.only(
                    topLeft: AppTheme.radiusBurbuja,
                    topRight: AppTheme.radiusBurbuja,
                    bottomLeft: isUser ? AppTheme.radiusBurbuja : Radius.zero,
                    bottomRight: isUser ? Radius.zero : AppTheme.radiusBurbuja,
                  ),
                  boxShadow: isUser ? null : [
                    BoxShadow(color: AppTheme.inkPrimary.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: Text(
                  message.text,
                  style: isUser ? AppTheme.bodyWhiteRegular : AppTheme.bodyPrimaryRegular,
                ),
              ),
            ],
          ),
          if (message.tips != null && message.tips!.isNotEmpty)
            Container(
              margin: const EdgeInsetsDirectional.only(bottom: AppTheme.espacioEntreCampos, top: AppTheme.espacioEntreLabelInput),
              padding: AppTheme.paddingEstandar,
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
              decoration: BoxDecoration(
                color: AppTheme.inkInverse,
                borderRadius: BorderRadiusDirectional.only(
                  topEnd: AppTheme.radiusBotonEsquina,
                  bottomStart: AppTheme.radiusBotonEsquina,
                  bottomEnd: AppTheme.radiusBotonEsquina,
                ),
                boxShadow: [
                   BoxShadow(color: AppTheme.navyPrimary.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
                ],
                border: BorderDirectional(
                  start: BorderSide(color: AppTheme.navyPrimary, width: AppTheme.radiusDetalles),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      Container(
                        padding: AppTheme.paddingCompacto,
                        decoration: BoxDecoration(
                          color: AppTheme.navyPrimary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.tips_and_updates, size: AppTheme.iconoPequeno, color: AppTheme.navyPrimary),
                      ),
                      const SizedBox(width: AppTheme.espacioEntreCampos),
                      Text(
                        l10n.tips.toUpperCase(), 
                        style: AppTheme.captionGreyRegular.copyWith(
                          fontWeight: FontWeight.w700, 
                          color: AppTheme.navyPrimary, 
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.espacioEntreGrupos),
                  ...message.tips!.map((tip) => Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: AppTheme.espacioEntreCampos),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('•', style: AppTheme.h2NavyBold),
                        const SizedBox(width: AppTheme.espacioEntreCampos),
                        Expanded(
                          child: Text(
                            tip, 
                            style: AppTheme.labelRegular.copyWith(color:AppTheme.inkSecondary),
                          ),
                        ),
                      ],
                    ),
                  )),
                  if (message.example != null) ...[
                    SizedBox(height: AppTheme.espacioEntreCampos),
                    Container(
                      padding: AppTheme.paddingCompacto,
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundGrey,
                        borderRadius: AppTheme.smallRadius,
                      ),
                      child: Row(
                        children: [
                           Icon(Icons.edit_note, size: AppTheme.iconoPequeno, color: AppTheme.inkSecondary),
                           const SizedBox(width: AppTheme.paddingHorizontalInput),
                           Expanded(
                             child: Text(
                               '${l10n.example}: ${message.example}', 
                               style: AppTheme.captionGreyRegular.copyWith(fontStyle: FontStyle.italic, color: AppTheme.inkSecondary)
                             ),
                           ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          SizedBox(height: AppTheme.espacioEntreCampos),
        ],
      ),
    );
  }
}
