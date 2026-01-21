import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/network/supabase_client.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_header.dart';
import 'package:mobile/features/ocr/logic/mrz_parser.dart';

/// Screen to confirm OCR-extracted passport data with full i18n.
/// Updated: 2026-01-21 - Applied i18n and AppHeader per audit requirements
class PassportConfirmScreen extends ConsumerStatefulWidget {
  final PassportModel passportData;
  
  const PassportConfirmScreen({super.key, required this.passportData});

  @override
  ConsumerState<PassportConfirmScreen> createState() => _PassportConfirmScreenState();
}

class _PassportConfirmScreenState extends ConsumerState<PassportConfirmScreen> {
  late TextEditingController _surnameController;
  late TextEditingController _givenNameController;
  late TextEditingController _birthDateController;
  late TextEditingController _nationalityController;
  late TextEditingController _passportNumberController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _surnameController = TextEditingController(text: widget.passportData.lastName);
    _givenNameController = TextEditingController(text: widget.passportData.firstName);
    _birthDateController = TextEditingController(text: _formatDate(widget.passportData.birthDate));
    _nationalityController = TextEditingController(text: widget.passportData.nationality);
    _passportNumberController = TextEditingController(text: widget.passportData.documentNumber);
  }

  String _formatDate(String yymmdd) {
    if (yymmdd.length != 6) return yymmdd;
    final yy = yymmdd.substring(0, 2);
    final mm = yymmdd.substring(2, 4);
    final dd = yymmdd.substring(4, 6);
    final century = int.parse(yy) > 30 ? '19' : '20';
    return '$dd/$mm/$century$yy';
  }

  @override
  void dispose() {
    _surnameController.dispose();
    _givenNameController.dispose();
    _birthDateController.dispose();
    _nationalityController.dispose();
    _passportNumberController.dispose();
    super.dispose();
  }

  Future<void> _confirmAndProceed() async {
    setState(() => _isLoading = true);
    final l10n = context.l10n;
    
    try {
      final supabase = ref.read(supabaseClientProvider);
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception(l10n.userNotAuthenticated);

      await supabase.from('applications').upsert({
        'user_id': userId,
        'form_data': {
          'surname': _surnameController.text.toUpperCase(),
          'given_name': _givenNameController.text.toUpperCase(),
          'birth_date': _birthDateController.text,
          'nationality': _nationalityController.text,
          'passport_number': _passportNumberController.text,
          'ocr_confirmed': true,
          'ocr_timestamp': DateTime.now().toIso8601String(),
        },
        'status': 'ocr_complete',
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      if (mounted) {
        context.push('/kyc/chat');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.error(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppHeader(title: l10n.confirmDataTitle),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '✅ ${l10n.passportScanned}',
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                        Text(
                          l10n.verifyDataCorrect,
                          style: TextStyle(color: Colors.green.shade700, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Editable Fields
            _buildField(l10n.surnameLabel, _surnameController, Icons.person),
            _buildField(l10n.givenNameLabel, _givenNameController, Icons.person_outline),
            _buildField(l10n.birthDateLabel, _birthDateController, Icons.cake),
            _buildField(l10n.nationalityLabel, _nationalityController, Icons.flag),
            _buildField(l10n.passportNumberLabel, _passportNumberController, Icons.credit_card),

            const SizedBox(height: 32),

            // Info box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.additionalQuestionsInfo,
                      style: TextStyle(color: Colors.blue.shade800, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmAndProceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.navyPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        l10n.confirmAndContinue,
                        style: context.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.navyPrimary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.navyPrimary, width: 2),
          ),
        ),
        textCapitalization: TextCapitalization.characters,
      ),
    );
  }
}
