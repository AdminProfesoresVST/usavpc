import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/network/supabase_client.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_header.dart';
import 'package:mobile/core/widgets/app_toast.dart';
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
  Map<String, dynamic> _formData = {};
  bool _isLoading = true;
  bool _isSending = false;

  // DS-260 SPECIFIC ALIASES
  final Map<String, String> _knownAliases = {
    'surnames': 'surname', // DS-260 uses 'surnames', OCR provides 'surname'
    'given_names': 'given_name', // DS-260 uses 'given_names', OCR provides 'given_name'
    'dob': 'birth_date',
    'passport_num': 'passport_number',
    'nationality': 'nationality',
    'gender': 'sex',
  };

  // Keys to skip if OCR data exists
  final Set<String> _alwaysSkipKeys = {
    'surnames', 'surname', 'last_name',
    'given_names', 'given_name', 'first_name',
    'birth_date', 'dob',
    'passport_number', 'passport_num',
    'nationality',
    'sex', 'gender'
  };

  final Set<String> _latinNationalities = {
    'MEX', 'DOM', 'COL', 'ARG', 'PER', 'VEN', 'CHL', 'ECU', 'GTM', 'CUB', 'ESP', 'USA', 'CAN', 
    'GBR', 'FRA', 'DEU', 'ITA', 'BRA', 'PRT', 'HND', 'SLV', 'PAN', 'CRI', 'URY', 'PRY', 'BOL'
  };

  String _debugError = '';

  @override
  void initState() {
    super.initState();
    _loadQuestions();
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
      
      // Load existing form data from DB
      if (userId != null) {
        final app = await supabase
            .from('applications')
            .select('form_data')
            .eq('user_id', userId)
            .maybeSingle();
            
        if (app != null && app['form_data'] != null) {
          final dbData = Map<String, dynamic>.from(app['form_data']);
          _formData.addAll(dbData);
        }
      }

      // Smart Skip - Nationality Logic
      String nat = _formData['nationality']?.toString().toUpperCase() ?? '';
      if (nat.contains('DOMINICA')) nat = 'DOM';
      else if (nat.contains('MEXIC')) nat = 'MEX';
      
      if (_latinNationalities.contains(nat) || _latinNationalities.contains(_formData['nationality'])) {
         if (!_formData.containsKey('native_alphabet_name')) _formData['native_alphabet_name'] = 'Does Not Apply'; 
         if (!_formData.containsKey('telecode_name')) _formData['telecode_name'] = 'No';
      }

      // Fetch DS-260 Questions specifically
      final rawQuestions = await supabase
          .from('ds260_questions') // HARDCODED TABLE
          .select()
          .order('section')
          .order('section_order');
 
      final totalFetched = (rawQuestions as List).length;

      if (totalFetched == 0) {
        if (mounted) AppToast.show(context, 'Error: No questions found in ds260_questions', isError: true);
        setState(() => _isLoading = false);
        return;
      }

      // DS-260 Section Order
      final sectionOrder = {
        'personal_1': 1,
        'personal_2': 2,
        'address': 3, // Mailing vs Address
        'contact': 4,
        'passport': 5,
        'travel_history': 6,
        'family_parents': 7, 
        'family_spouse': 8,
        'family_children': 9,
        'work_education': 10,
        'security_health': 11,
        'security_criminal': 12,
        'security_security': 13,
        'security_immigration': 14,
        'security_misc': 15,
        'ssn': 16,
      };

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

      // Filter Logic
      var filteredQuestions = rawQuestions.where((q) {
        final fieldKey = q['field_key'] as String;
        final normalizedKey = _knownAliases[fieldKey] ?? fieldKey;
        
        final hasData = _formData.containsKey(fieldKey) || _formData.containsKey(normalizedKey);
        final dataValue = _formData[fieldKey] ?? _formData[normalizedKey];

        if (hasData && dataValue != null && dataValue.toString().isNotEmpty) {
           if (_alwaysSkipKeys.contains(fieldKey) || _alwaysSkipKeys.contains(normalizedKey)) return false;
           if (q['skip_if_ocr'] == true) return false;
        }

        if (q['depends_on'] != null && q['depends_on_value'] != null) {
          final dependKey = q['depends_on'];
          final dependAlias = _knownAliases[dependKey] ?? dependKey;
          final dependValue = _formData[dependKey] ?? _formData[dependAlias];

          if (dependValue.toString() != q['depends_on_value'].toString()) return false;
        }
        return true;
      }).toList().cast<Map<String, dynamic>>();

      _questions = filteredQuestions.isNotEmpty ? filteredQuestions : rawQuestions.toList().cast<Map<String, dynamic>>();

      if (_questions.isEmpty) {
         if (mounted) AppToast.show(context, 'No active DS-260 questions available.', isError: true);
         setState(() => _isLoading = false);
         return;
      }
      
      setState(() => _isLoading = false);
      _askNextQuestion();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.show(context, 'Error loading DS-260: $e', isError: true);
      }
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
        title: 'Asistente DS-260',
        subtitle: totalQuestions > 0 
            ? 'Pregunta ${answeredQuestions + 1} de $totalQuestions'
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
                    ),
                  ),
                ),
                _buildInputArea(),
              ],
            ),
    );
  }

  Widget _buildInputArea() {
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
                  hintText: 'Escribe tu respuesta...',
                  filled: true,
                  fillColor: AppTheme.dividerGreyLight,
                  contentPadding: AppTheme.paddingCampo,
                  border: OutlineInputBorder(
                    borderRadius: AppTheme.badgeRadius,
                    borderSide: BorderSide.none,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            SizedBox(width: AppTheme.espacioEntreCampos),
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.navyPrimary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _isSending ? null : _handleSend,
                icon: _isSending
                    ? const SizedBox(
                        width: AppTheme.iconoEnTarjeta,
                        height: AppTheme.iconoEnTarjeta,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.inkInverse),
                      )
                    : const Icon(Icons.send, color: AppTheme.inkInverse, size: AppTheme.iconoEnTarjeta),
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
          Container(
            margin: const EdgeInsetsDirectional.only(bottom: AppTheme.espacioEntreLabelInput),
            padding: AppTheme.paddingCampo,
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
