import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:mobile/core/widgets/app_header.dart';
import 'package:mobile/core/widgets/app_toast.dart';
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
  late TextEditingController _sexController;
  late TextEditingController _expiryDateController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // NUCLEAR CLEAN: Remove any lingering snackbars from scanner
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).clearSnackBars();
    });

    _surnameController = TextEditingController(text: widget.passportData.lastName);
    _givenNameController = TextEditingController(text: widget.passportData.firstName);
    _birthDateController = TextEditingController(text: _formatDate(widget.passportData.birthDate));
    _nationalityController = TextEditingController(text: widget.passportData.nationality);
    _passportNumberController = TextEditingController(text: widget.passportData.documentNumber);
    _sexController = TextEditingController(text: widget.passportData.sex);
    _expiryDateController = TextEditingController(text: _formatDate(widget.passportData.expiryDate));
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
    _sexController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  Future<void> _confirmAndProceed() async {
    setState(() => _isLoading = true);
    final l10n = context.l10n;
    
    try {
      final dashboardRepo = ref.read(dashboardRepositoryProvider);
      
      // Check existing application via Repository
      final profileData = await dashboardRepo.getProfileData();
      final existing = profileData['app'];

      final dataToSave = {
        'form_data': {
          'surname': _surnameController.text.toUpperCase(),
          'given_name': _givenNameController.text.toUpperCase(),
          'birth_date': _birthDateController.text,
          'nationality': _nationalityController.text,
          'passport_number': _passportNumberController.text.toUpperCase(),
          'sex': _sexController.text.toUpperCase(),
          'passport_expiry': _expiryDateController.text,
          'ocr_confirmed': true,
          'ocr_timestamp': DateTime.now().toIso8601String(),
        },
        'status': 'ocr_complete',
      };

      if (existing != null) {
        await dashboardRepo.updateApplication(dataToSave);
      } else {
        await dashboardRepo.createApplication(dataToSave);
      }

      if (mounted) {
        // Navigate immediately - User requested no "Success" toast
        if (mounted) {
          final formType = GoRouterState.of(context).uri.queryParameters['form'] ?? 'ds160';
          final targetPath = formType == 'ds260' ? '/kyc/ds260' : '/kyc/chat';

          context.push(Uri(path: targetPath, queryParameters: {
            // Preserve logic
            ...GoRouterState.of(context).uri.queryParameters,
            'surname': _surnameController.text.toUpperCase(),
            'given_name': _givenNameController.text.toUpperCase(),
            'dob': _birthDateController.text,
            'nationality': _nationalityController.text,
            'passport': _passportNumberController.text.toUpperCase(),
             'sex': _sexController.text.toUpperCase(),
             'expiry': _expiryDateController.text,
          }).toString());
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().contains('42P10') 
            ? l10n.errorDatabaseUnique 
            : l10n.error(e.toString());
        AppToast.show(context, errorMsg, isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    final formType = GoRouterState.of(context).uri.queryParameters['form']?.toUpperCase();
    final title = formType != null ? '${l10n.confirmDataTitle} ($formType)' : l10n.confirmDataTitle;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppHeader(title: title),
      body: SingleChildScrollView(
        padding: AppTheme.paddingGrande,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            // Header Removed per user request
            SizedBox(height: AppTheme.espacioEntreCampos),
            SizedBox(height: AppTheme.espacioEntreCards),

            // Editable Fields
            _buildField(l10n.surnameLabel, _surnameController, Icons.person),
            _buildField(l10n.givenNameLabel, _givenNameController, Icons.person_outline),
            _buildField(l10n.birthDateLabel, _birthDateController, Icons.cake),
            _buildField(l10n.nationalityLabel, _nationalityController, Icons.flag),
            _buildField(l10n.passportNumberLabel, _passportNumberController, Icons.credit_card),
             Row(
              children: [
                Expanded(child: _buildField(l10n.sexLabel, _sexController, Icons.person)),
                SizedBox(width: AppTheme.paddingTarjetas),
                Expanded(child: _buildField(l10n.expiryDateLabel, _expiryDateController, Icons.calendar_today)),
              ],
            ),

            SizedBox(height: AppTheme.espacioEntreBloques),

            // Info box
            // Info box removed per user request

            SizedBox(height: AppTheme.espacioEntreCards),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: AppTheme.alturaBotonGrande,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmAndProceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.navyPrimary,
                  foregroundColor: AppTheme.inkInverse,
                  shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: AppTheme.iconoEnTarjeta,
                        height: AppTheme.iconoEnTarjeta,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.inkInverse),
                      )
                    : Text(
                        l10n.confirmAndContinue,
                        style: AppTheme.h2NavyBold.copyWith(
                          color: AppTheme.inkInverse,
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
      padding: const EdgeInsetsDirectional.only(bottom: AppTheme.paddingTarjetas),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.navyPrimary),
          filled: true,
          fillColor: AppTheme.inkInverse,
          border: OutlineInputBorder(
            borderRadius: AppTheme.buttonRadius,
            borderSide: BorderSide(color: AppTheme.inkSecondary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppTheme.buttonRadius,
            borderSide: const BorderSide(color: AppTheme.navyPrimary, width: AppTheme.alturaBotonPequeno),
          ),
        ),
        textCapitalization: TextCapitalization.characters,
      ),
    );
  }
}
