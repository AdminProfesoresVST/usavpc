import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/network/supabase_client.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_header.dart';
import 'package:mobile/core/widgets/app_toast.dart';
import 'package:mobile/services/voice_manager.dart'; // Import VoiceManager
import 'package:mobile/core/widgets/premium_chat_input.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Dedicated intake screen for DS-260 (Immigrant Visa)
/// Separated from DS-160 to handle specific aliases and flow requirements.
class Ds260IntakeScreen extends ConsumerStatefulWidget {
  const Ds260IntakeScreen({super.key});

  @override
  ConsumerState<Ds260IntakeScreen> createState() => _Ds260IntakeScreenState();
}

class _Ds260IntakeScreenState extends ConsumerState<Ds260IntakeScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  final Map<String, dynamic> _formData = {};
  bool _isLoading = true;
  bool _isInit = true;
  bool _isSending = false;
  // DEBUG VARIABLES
  String _debugError = '';
  final int _debugFetched = -1;
  final int _debugFiltered = -1;

  // VOICE
  final VoiceManager _voiceManager = VoiceManager();
  bool _isListening = false;

  // DS-260 SPECIFIC ALIASES
  final Map<String, String> _knownAliases = {
    'surnames': 'surname', // DS-260 uses 'surnames', OCR provides 'surname'
    'given_names': 'given_name', // DS-260 uses 'given_names', OCR provides 'given_name'
    'dob': 'birth_date',
    'passport_num': 'passport_number',
    'nationality': 'nationality',
    'gender': 'sex',
    'native_alphabet': 'native_alphabet_name',
    'native_name': 'native_alphabet_name',
    'telecode': 'telecode_name',
    'other_names_used': 'other_names', 
    'other_names_list': 'other_names',

    // SCHEMA COMPATIBILITY MAPPINGS (Critical Fix)
    // Note: DS-260 usually uses flat keys, but if it uses nested keys like DS-160, we map them here.
    // Assuming DS-260 Migration might have similar nested structure or will have in future.
    // Adding defensive mappings just in case.
    'ds260_data.personal.native_name': 'native_name',
    'ds260_data.personal.telecode_name': 'telecode_name',
    'ds260_data.personal.other_names_used': 'other_names_used',
    'ds260_data.personal.other_names_list': 'other_names_list',
    'native_name': 'native_alphabet_name', // Double alias
    'telecode_name': 'telecode', // Double alias
  };

  // Keys to skip if OCR data exists
  final Set<String> _alwaysSkipKeys = {
    'surnames', 'surname', 'last_name',
    'given_names', 'given_name', 'first_name',
    'birth_date', 'dob',
    'passport_number', 'passport_num',
    'nationality',
    'sex', 'gender',
    'native_alphabet_name', 'native_alphabet', 'native_name',
    'telecode_name', 'telecode', 'telecode_status',
    'other_names_used', 'other_names',
    'ds260_data.personal.native_name', 'ds260_data.personal.telecode_name',
    'ds260_data.personal.other_names_used'
  };

  final Set<String> _latinNationalities = {
    'MEX', 'DOM', 'COL', 'ARG', 'PER', 'VEN', 'CHL', 'ECU', 'GTM', 'CUB', 'ESP', 'USA', 'CAN', 
    'GBR', 'FRA', 'DEU', 'ITA', 'BRA', 'PRT', 'HND', 'SLV', 'PAN', 'CRI', 'URY', 'PRY', 'BOL'
  };



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _loadQuestions();
      _voiceManager.initialize(); // Initialize Voice
      _isInit = false;
    }
  }

  @override
  void initState() {
    super.initState();
    // Moved _loadQuestions to didChangeDependencies
  }

  Future<void> _loadQuestions() async {
    try {
      final state = GoRouterState.of(context);
      final params = state.uri.queryParameters;
      
      // Load initial params from OCR/Previous screens
      if (params.isNotEmpty) {
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
          supabase.from('ds260_questions').select().order('section').order('section_order'),
        ]);

        appData = responses[0] as Map<String, dynamic>?;
        profileData = responses[1] as Map<String, dynamic>?;
        rawQuestions = responses[2] as List<dynamic>;
      } else {
         rawQuestions = await supabase
          .from('ds260_questions')
          .select()
          .order('section')
          .order('section_order');
      }

      // 1. Hydrate from Application
      if (appData != null && appData['form_data'] != null) {
        final dbData = Map<String, dynamic>.from(appData['form_data']);
        _formData.addAll(dbData);
      }

      // 2. Hydrate from Profile
      if (_formData['nationality'] == null && profileData != null) {
         final profileNat = profileData['nationality'] ?? profileData['citizenship'] ?? profileData['country'];
         if (profileNat != null) {
           _formData['nationality'] = profileNat.toString().toUpperCase();
         }
      }

      // 3. Smart Skip - Nationality Logic
      String nat = _formData['nationality']?.toString().toUpperCase() ?? '';
      if (nat.contains('DOMINICA')) {
        nat = 'DOM';
      } else if (nat.contains('MEXIC')) nat = 'MEX';

      final isLatin = _latinNationalities.contains(nat) || _latinNationalities.contains(_formData['nationality']);
      
      if (isLatin) {
         // NUCLEAR INJECTION: Set ALL variants to ensures usage
         _formData['native_alphabet_name'] = 'Does Not Apply'; 
         _formData['native_alphabet'] = 'Does Not Apply';
         _formData['native_name'] = 'Does Not Apply';

         _formData['telecode_name'] = 'No';
         _formData['telecode'] = 'No';
         _formData['telecode_status'] = 'No';

         // INJECT SCHEMA KEYS TOO
         _formData['ds260_data.personal.native_name'] = 'Does Not Apply';
         _formData['ds260_data.personal.telecode_name'] = 'No';
      }
 
      final totalFetched = (rawQuestions as List).length;

      if (totalFetched == 0) {
        _debugError = 'Error: No questions found in ds260_questions';
        setState(() => _isLoading = false);
        return;
      }

      // CAST to List<Map> for manipulation
      var questionsList = rawQuestions.toList().cast<Map<String, dynamic>>();

      // CONTEXT RECOVERY: If Nationality is missing, ASK IT FIRST!
      if (_formData['nationality'] == null) {
          final natIndex = questionsList.indexWhere((q) => q['field_key'] == 'nationality');
          if (natIndex != -1) {
            final natQ = questionsList.removeAt(natIndex);
            questionsList.insert(0, natQ); // Move to TOP
          }
      }

      // DS-260 Section Order
      final sectionOrder = {
        'personal_1': 1,
        'personal_2': 2,
        'contact': 3,
        'address_mailing': 4, 
        'family_parents': 5, 
        'family_spouse': 6,
        'family_children': 7,
        'travel_history': 8, 
        'work_education': 9,
        'petitioner': 10, 
        'security_health': 11,
        'security_criminal': 12,
        'security_security': 13,
        'security_immigration': 14,
        'security_misc': 15,
        'ssn': 16,
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
        final fieldKey = q['field_key'] as String;
        final normalizedKey = _knownAliases[fieldKey] ?? fieldKey;
        
        // 1. Smart Skip Check
        // If it's in _alwaysSkipKeys OR if we have data and it's an OCR field
        if (_alwaysSkipKeys.contains(fieldKey) || _alwaysSkipKeys.contains(normalizedKey)) {
             if (_formData.containsKey(fieldKey) || _formData.containsKey(normalizedKey)) {
                  // Explicitly check for non-empty data
                  final val = _formData[fieldKey] ?? _formData[normalizedKey];
                  if (val != null && val.toString().isNotEmpty) {
                      return false;
                  }
             }
        }

        // 4. Dependency Check (CASE INSENSITIVE FIX)
        if (q['depends_on'] != null && q['depends_on_value'] != null) {
          final dependKey = q['depends_on'];
          final dependAlias = _knownAliases[dependKey] ?? dependKey;
          var dependValue = _formData[dependKey] ?? _formData[dependAlias]; 
          
          if (dependValue == null && dependKey == 'other_names_used') {
             // Fallback for tricky other names logic
             dependValue = _formData['other_names'] ?? _formData['other_names_list'];
          }

          // Fallback check for schema keys
          if (dependValue == null && dependKey.startsWith('ds260_data')) {
             // Try to find the short key version in formData
             final shortKey = dependKey.split('.').last;
             dependValue = _formData[shortKey];
          }

          final requiredVal = q['depends_on_value'].toString().trim().toLowerCase();
          final actualVal = dependValue?.toString().trim().toLowerCase() ?? '';

          // Special Boolean Handling
          if (requiredVal == 'true' || requiredVal == 'yes') {
             if (actualVal != 'true' && actualVal != 'yes' && actualVal != '1') return false;
          } else if (requiredVal == 'false' || requiredVal == 'no') {
             if (actualVal != 'false' && actualVal != 'no' && actualVal != '0') return false;
          } else {
             // Standard String match
             if (actualVal != requiredVal) return false;
          }
        }
        return true;
      }).toList().cast<Map<String, dynamic>>();

      _questions = filteredQuestions.isNotEmpty ? filteredQuestions : rawQuestions.toList().cast<Map<String, dynamic>>();

      if (_questions.isEmpty) {
          _debugError = 'Filtered list is empty (Raw=$totalFetched). Check Skip/Smart Logic.';
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

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

  void _askNextQuestion() {
    try {
      if (_currentQuestionIndex >= _questions.length) {
        _completeIntake();
        return;
      }

      final question = _questions[_currentQuestionIndex];
      final tipsList = question['tips'] as List?;
      final tips = tipsList?.map((e) => e.toString()).toList() ?? <String>[];
      final example = question['example_good']?.toString();
      final questionText = question['question_friendly']?.toString() ?? 'Error: Missing Question Text';
      
      _addBotMessage(questionText, tips: tips, example: example);
    } catch (e) {
      if (mounted) AppToast.show(context, 'Error displaying question: $e', isError: true);
    }
  }

  Future<void> _handleSend() async {
    if (_isSending) return;
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

      _formData[fieldKey] = text;
      
      final supabase = ref.read(supabaseClientProvider);
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final existing = await supabase
            .from('applications')
            .select('id')
            .eq('user_id', userId)
            .maybeSingle();

        final dataToSave = {
          'user_id': userId,
          'form_data': _formData,
          'form_type': 'DS-260', // Explicitly mark application type
        };

        if (existing != null) {
          await supabase.from('applications').update(dataToSave).eq('id', existing['id']);
        } else {
          await supabase.from('applications').insert(dataToSave);
        }
      }

      _currentQuestionIndex++;
      _askNextQuestion();
    } catch (e) {
       if (mounted) _addBotMessage('Error saving response: ${e.toString()}');
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _completeIntake() {
    _addBotMessage('DS-260 Intake Complete.');
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: '', isUser: false, isAction: true));
        });
        _scrollToBottom();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalQuestions = _questions.length;
    final answeredQuestions = _currentQuestionIndex;
    final progress = totalQuestions > 0 ? answeredQuestions / totalQuestions : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppHeaderWithProgress(
        title: context.l10n.ds260IntakeTitle,
        subtitle: totalQuestions > 0 
            ? context.l10n.questionProgress(answeredQuestions + 1, totalQuestions)
            : null,
        progress: progress,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
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
                if (kDebugMode && (_debugError.isNotEmpty || (_questions.isEmpty && !_isLoading)))
                  _buildDebugOverlay(),
                _buildInputArea(),
              ],
            ),
    );
  }

  Widget _buildDebugOverlay() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Icon(Icons.warning_amber_rounded, size: 60, color: Colors.orange),
               SizedBox(height: 20),
               Text(
                 'DS-260 Introspection',
                 style: AppTheme.h2NavyBold,
                 textAlign: TextAlign.center,
               ),
               SizedBox(height: 10),
               Text(
                 'Preguntas Cargadas: $_debugFetched\nFiltradas: $_debugFiltered\nForm Data Params: ${_formData.length}',
                 style: AppTheme.bodyPrimaryRegular,
                 textAlign: TextAlign.center,
               ),
               SizedBox(height: 20),
               if (_debugError.isNotEmpty)
                 Container(
                   padding: const EdgeInsets.all(12),
                   decoration: BoxDecoration(
                     color: Colors.red.shade50,
                     border: Border.all(color: Colors.red),
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: Text(
                     _debugError,
                     style: TextStyle(color: Colors.red.shade900, fontFamily: 'Courier', fontSize: 12),
                   ),
                 ),
               SizedBox(height: 20),
               ElevatedButton(
                 onPressed: () {
                   setState(() {
                     _isLoading = true;
                     _debugError = '';
                     _formData.clear();
                   });
                   _loadQuestions();
                 },
                 child: Text('REINTENTAR CARGA'),
               ),
               SizedBox(height: 20),
               Text('Form Data Keys found:', style: TextStyle(fontWeight: FontWeight.bold)),
               Text(_formData.keys.join(', '), style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
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
          child: Text('Ver Solicitud', style: AppTheme.h2NavyBold.copyWith(color: AppTheme.inkInverse)),
        ),
      );
    }

    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
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
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.70),
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
              margin: const EdgeInsetsDirectional.only(bottom: AppTheme.espacioEntreCampos, top: AppTheme.espacioEntreLabelInput, start: 40),
              padding: AppTheme.paddingEstandar,
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.70),
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
                        Icon(Icons.tips_and_updates, size: AppTheme.iconoPequeno, color: AppTheme.navyPrimary),
                        const SizedBox(width: AppTheme.espacioEntreCampos),
                        Text('TIPS', style: AppTheme.captionGreyRegular.copyWith(fontWeight: FontWeight.bold, color: AppTheme.navyPrimary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...message.tips!.map((tip) => Text('• $tip', style: AppTheme.labelRegular)),
                  ],
              ),
            ),
          SizedBox(height: AppTheme.espacioEntreCampos),
        ],
      ),
    );
  }
}
