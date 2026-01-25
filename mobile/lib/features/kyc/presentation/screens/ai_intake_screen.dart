import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/network/supabase_client.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_header.dart';
import 'package:mobile/core/widgets/app_toast.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // FIXED: Added missing import

/// AI-powered chat intake with full i18n support.
class AiIntakeScreen extends ConsumerStatefulWidget {
  const AiIntakeScreen({super.key});

  @override
  ConsumerState<AiIntakeScreen> createState() => _AiIntakeScreenState();
}

class _AiIntakeScreenState extends ConsumerState<AiIntakeScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  Map<String, dynamic> _formData = {};
  bool _isLoading = true;
  bool _isSending = false;

  // SMART SKIP: Aliases to map DB keys to OCR keys
  final Map<String, String> _knownAliases = {
    'last_name': 'surname',
    'first_name': 'given_name',
    'dob': 'birth_date',
    'passport_num': 'passport_number',
    'nationality': 'nationality', // usually matches
    'gender': 'sex',
  };

  // SMART SKIP: Keys that must ALWAYS be skipped if they exist in FormData (OCR)
  final Set<String> _alwaysSkipKeys = {
    'surname', 'given_name', 'birth_date', 'passport_number', 'nationality', 'sex',
    'last_name', 'first_name', 'dob', 'passport_num', 'gender',
    'native_alphabet_name', 'other_names', 'telecode_name' // Skip "Native Name" questions if any identity data exists
  };

  // SMART SKIP: Nationalities that use Latin alphabet (Verification V2)
  // If user is from these countries, 'native_alphabet_name' is implicitly "Does Not Apply"
  final Set<String> _latinNationalities = {
    'MEX', 'DOM', 'COL', 'ARG', 'PER', 'VEN', 'CHL', 'ECU', 'GTM', 'CUB', 'ESP', 'USA', 'CAN', 
    'GBR', 'FRA', 'DEU', 'ITA', 'BRA', 'PRT', 'HND', 'SLV', 'PAN', 'CRI', 'URY', 'PRY', 'BOL'
  };

  // DEBUG STATS
  int _debugFetched = -1;
  int _debugFiltered = -1;
  String _debugError = '';

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final supabase = ref.read(supabaseClientProvider);
      
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final app = await supabase
            .from('applications')
            .select('form_data')
            .eq('user_id', userId)
            .maybeSingle();
        if (app != null && app['form_data'] != null) {
          _formData = Map<String, dynamic>.from(app['form_data']);
        }

      // SMART SKIP V2: Auto-fill fields based on Nationality (Latin Alphabet)
      final nat = _formData['nationality']?.toString().toUpperCase();
      if (nat != null && _latinNationalities.contains(nat)) {
         if (!_formData.containsKey('native_alphabet_name')) {
            debugPrint('VERIFICATION: Auto-filling native_alphabet_name for Latin Nationality: $nat');
            _formData['native_alphabet_name'] = 'Does Not Apply'; 
         }
         // Telecode is rarely used in LatAm
         if (!_formData.containsKey('telecode_name')) {
            _formData['telecode_name'] = 'No';
         }
      }
      }

      // Fetch raw questions - REMOVED is_active filter to ensure visibility if seed was partial
      final rawQuestions = await supabase
          .from('ds160_questions')
          .select()
          .order('section')
          .order('section_order');
 
      final totalFetched = (rawQuestions as List).length;

      // CRITICAL DATA INTEGRITY CHECK
      if (totalFetched == 0) {
        if (mounted) {
           // ZERO TOLERANCE: Do not fake data. Report the missing data.
           AppToast.show(
             context, 
             'CRITICAL ERROR: No Questions found in Database (0). Seeding required.', 
             isError: true
           );
        }
        setState(() => _isLoading = false);
        return;
      }

      debugPrint('VERIFICATION: Total raw questions fetched: $totalFetched');
      // 4. Custom Local Sort (Because alphabetical 'section' sort fails: 'previous' comes before 'personal'?)
    // Define the correct flow order explicitly
    final sectionOrder = {
      'personal': 1,
      'address': 2,
      'passport': 3,
      'travel': 4,
      'family': 5,
      'work': 6,
      'security': 7,
    };

    // Sort: 1. Defined Section Order, 2. Section Order (Db field), 3. ID (fallback)
    rawQuestions.sort((a, b) {
      final secA = a['section'] as String? ?? '';
      final secB = b['section'] as String? ?? '';
      
      final orderA = sectionOrder[secA] ?? 99;
      final orderB = sectionOrder[secB] ?? 99;
      
      if (orderA != orderB) return orderA.compareTo(orderB);
      
      final secOrderA = a['section_order'] as int? ?? 0;
      final secOrderB = b['section_order'] as int? ?? 0;
      
      return secOrderA.compareTo(secOrderB);
    });

      if (totalFetched > 0) {
        debugPrint('VERIFICATION: Sample Question Keys: ${rawQuestions.first.keys.toList()}');
      }

      // Filter Logic
      var filteredQuestions = rawQuestions.where((q) {
        final fieldKey = q['field_key'] as String;
        
        // 1. Resolve Alias
        final normalizedKey = _knownAliases[fieldKey] ?? fieldKey;

        // 2. Check Existence
        // We check both the raw key AND the normalized key in formData
        final hasData = _formData.containsKey(fieldKey) || _formData.containsKey(normalizedKey);
        final dataValue = _formData[fieldKey] ?? _formData[normalizedKey];

        // 3. Smart Skip Logic
        if (hasData && dataValue != null && dataValue.toString().isNotEmpty) {
           // A. Forced Skip (Zero Tolerance for Name/Passport redundancy)
           if (_alwaysSkipKeys.contains(fieldKey) || _alwaysSkipKeys.contains(normalizedKey)) {
             debugPrint('VERIFICATION: Smart Skipping $fieldKey (Found OCR data: $normalizedKey)');
             return false;
           }

           // B. DB Flag Skip
           if (q['skip_if_ocr'] == true) {
             debugPrint('VERIFICATION: Skipping $fieldKey (DB Flag + Data Present)');
             return false;
           }
        }

        if (q['depends_on'] != null && q['depends_on_value'] != null) {
          final dependKey = q['depends_on'];
          final dependAlias = _knownAliases[dependKey] ?? dependKey;
          final dependValue = _formData[dependKey] ?? _formData[dependAlias]; // Check both

          if (dependValue.toString() != q['depends_on_value'].toString()) {
            // debugPrint('VERIFICATION: Skipping $fieldKey (Dependency not met: $dependKey=$dependValue != ${q['depends_on_value']})');
            return false;
          }
        }
        return true;
      }).toList().cast<Map<String, dynamic>>();

      debugPrint('VERIFICATION: Questions after filtering: ${filteredQuestions.length}');
      _debugFetched = totalFetched;
      _debugFiltered = filteredQuestions.length;

      debugPrint('VERIFICATION: Questions after filtering: ${filteredQuestions.length}');
      _debugFetched = totalFetched;
      _debugFiltered = filteredQuestions.length;

      // FORCE RAW if filter is too aggressive
      if (filteredQuestions.isEmpty && totalFetched > 0) {
         debugPrint('VERIFICATION: All filtered! Forcing raw questions to avoid empty screen.');
         _questions = rawQuestions.toList().cast<Map<String, dynamic>>();
      } else {
         _questions = filteredQuestions;
      }

      // NO HARDCODED FALLBACKS ALLOWED
      if (_questions.isEmpty) {
         _debugError = 'DB returned 0 questions (Raw=$totalFetched)';
         debugPrint('VERIFICATION FAILURE: Questions list is EMPTY after all checks.');
         if (mounted) {
            AppToast.show(context, 'CRITICAL: No questions available to render.', isError: true);
         }
         setState(() => _isLoading = false);
         return;
      }
      
      debugPrint('VERIFICATION SUCCESS: Starting chat with ${_questions.length} questions.');
      setState(() => _isLoading = false);
      _askNextQuestion();
    } catch (e) {
      _debugError = e.toString();
      debugPrint('DEBUG: Error loading questions: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.show(context, 'DB Auth Error: Maybe RLS? ${e.toString()}', isError: true);
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
      // Robust casting with fallbacks
      final tips = question['tips'] is List ? (question['tips'] as List).map((e) => e.toString()).toList() : <String>[];
      final example = question['example_good']?.toString();
      final questionText = question['question_friendly']?.toString() ?? 'Error: Missing Question Text';
      
      _addBotMessage(questionText, tips: tips, example: example);
    } catch (e) {
      setState(() => _debugError = 'AskNext Crash: $e');
    }
  }

  Future<void> _handleSend() async {
    debugPrint('DEBUG: _handleSend called. isSending: $_isSending');
    if (_isSending) return;
    
    // GUARD: If no questions, simply complete
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) {
       debugPrint('DEBUG: No questions left or empty list. Completing.');
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
      debugPrint('DEBUG: Answering question: $fieldKey with "$text"');

      // ... regex validation ...

      _formData[fieldKey] = text;
      
      final supabase = ref.read(supabaseClientProvider);
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        debugPrint('DEBUG: Saving to DB for user: $userId');
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
        debugPrint('DEBUG: Save success.');
      }

      _currentQuestionIndex++;
      _askNextQuestion();
    } catch (e) {
       debugPrint('DEBUG: Error in _handleSend: $e');
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
        title: l10n.ds160Assistant,
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
                    ),
                  ),
                ),
                _buildInputArea(l10n),
              ],
            ),
    );
  }

  Widget _buildInputArea(dynamic l10n) {
    return Container(
      padding: AppTheme.paddingEstandar,
      decoration: BoxDecoration(
        color: AppTheme.inkInverse,
        boxShadow: [
          BoxShadow(color: AppTheme.inkPrimary.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: l10n.typeYourResponse,
                  hintStyle: AppTheme.labelRegular.copyWith(color: AppTheme.inkSecondary),
                  filled: true,
                  fillColor: AppTheme.dividerGreyLight,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Reduced vertical
                  border: OutlineInputBorder(
                    borderRadius: AppTheme.badgeRadius, // Reduced from 24
                    borderSide: BorderSide.none,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.navyPrimary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _isSending ? null : _handleSend,
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.inkInverse),
                      )
                    : const Icon(Icons.send, color: AppTheme.inkInverse, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
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

  const _ChatBubble({required this.message, this.onAction});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    if (message.isAction) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ElevatedButton(
          onPressed: onAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.navyPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
          Container(
            margin: const EdgeInsetsDirectional.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
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
          if (message.tips != null && message.tips!.isNotEmpty)
            Container(
              margin: const EdgeInsetsDirectional.only(bottom: 8, top: 4),
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
                  start: BorderSide(color: AppTheme.navyPrimary, width: 4),
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
                      const SizedBox(width: 8),
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
                    padding: const EdgeInsetsDirectional.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('•', style: AppTheme.h2NavyBold),
                        const SizedBox(width: 8),
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
                           const SizedBox(width: 6),
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
