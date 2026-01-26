import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_header.dart';
import 'package:mobile/core/widgets/app_alerts.dart';
import 'package:mobile/features/risk_audit/presentation/providers/application_provider.dart';
import 'package:mobile/features/visa/presentation/providers/visa_providers.dart';
import 'package:mobile/features/visa/data/helpers/visa_localization_helper.dart';

/// Quick check screen with full i18n support.
/// Updated: 2026-01-21 - Applied i18n and AppHeader per audit requirements
class QuickCheckScreen extends ConsumerStatefulWidget {
  const QuickCheckScreen({super.key});

  @override
  ConsumerState<QuickCheckScreen> createState() => _QuickCheckScreenState();
}

class _QuickCheckScreenState extends ConsumerState<QuickCheckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ds160Controller = TextEditingController();
  String _selectedVisaType = 'B1/B2';
  bool _hasDs160 = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final quickCheckState = ref.watch(quickCheckNotifierProvider);

    ref.listen(quickCheckNotifierProvider, (previous, next) {
      if (next.error != null && (previous?.error != next.error)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.error(next.error ?? ''))),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppHeader(title: l10n.preliminaryAuditTitle),
      body: SingleChildScrollView(
        padding: AppTheme.paddingGrande,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                l10n.eligibilityVerification,
                style: AppTheme.h1NavyBold,
              ),
              SizedBox(height: AppTheme.espacioEntreCampos),
              Text(
                l10n.eligibilitySubtitle,
                style: AppTheme.labelRegular.copyWith(height: 1.5),
              ),
              SizedBox(height: AppTheme.espacioEntreBloques),

              // Question 1: Visa Type (loaded from Supabase)
              Text(
                l10n.visaTypeLabel,
                style: AppTheme.h2NavyBold,
              ),
              SizedBox(height: AppTheme.espacioEntreCampos),
              Consumer(
                builder: (context, ref, _) {
                  final categoriesAsync = ref.watch(visaCategoriesProvider);
                  return categoriesAsync.when(
                    loading: () => Container(
                      padding: AppTheme.paddingEstandar,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.dividerGrey),
                        borderRadius: AppTheme.smallRadius,
                        color: AppTheme.inkInverse,
                      ),
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    error: (e, _) => Container(
                      padding: AppTheme.paddingPequeno,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.errorRed),
                        borderRadius: AppTheme.smallRadius,
                        color: AppTheme.inkInverse,
                      ),
                      child: Text('Error: $e', style: TextStyle(color: AppTheme.errorRed)),
                    ),
                    data: (categories) {
                      // Asegurar que el valor seleccionado existe en la lista
                      if (!categories.any((c) => c.code == _selectedVisaType) && categories.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() => _selectedVisaType = categories.first.code);
                          }
                        });
                      }
                      return Container(
                        padding: AppTheme.paddingBadge,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.dividerGrey),
                          borderRadius: AppTheme.smallRadius,
                          color: AppTheme.inkInverse,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: categories.any((c) => c.code == _selectedVisaType) 
                                ? _selectedVisaType 
                                : (categories.isNotEmpty ? categories.first.code : null),
                            isExpanded: true,
                            menuMaxHeight: 400, // Altura máxima del menú
                            items: categories.map((category) {
                              return DropdownMenuItem(
                                value: category.code,
                                child: Text(
                                  VisaLocalizationHelper.getLocalizedName(l10n, category.code),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedVisaType = val);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: AppTheme.espacioEntreCards),

              // Question 2: DS-160
              Text(
                l10n.ds160Question,
                style: AppTheme.h2NavyBold,
              ),
              SizedBox(height: AppTheme.espacioEntreCampos),
              Row(
                children: [
                  Expanded(
                    child: _RadioOption(
                      label: l10n.yesHaveCode,
                      selected: _hasDs160,
                      onTap: () => setState(() => _hasDs160 = true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RadioOption(
                      label: l10n.notYet,
                      selected: !_hasDs160,
                      onTap: () => setState(() => _hasDs160 = false),
                    ),
                  ),
                ],
              ),
              
              if (_hasDs160) ...[
                SizedBox(height: AppTheme.espacioEntreCards),
                Text(
                  l10n.ds160CodeLabel,
                  style: AppTheme.h2NavyBold,
                ),
                SizedBox(height: AppTheme.espacioEntreCampos),
                TextFormField(
                  controller: _ds160Controller,
                  decoration: InputDecoration(
                    hintText: l10n.ds160CodeHint,
                    border: OutlineInputBorder(borderRadius: AppTheme.inputRadius),
                    contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.paddingHorizontalInput, vertical: AppTheme.paddingVerticalInput),
                    fillColor: AppTheme.inkInverse,
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return l10n.enterCode;
                    if (!value.toUpperCase().startsWith('AA')) return l10n.codeStartAA;
                    return null;
                  },
                ),
              ],
              
               if (!_hasDs160) ...[
                SizedBox(height: AppTheme.espacioEntreCards),
                 AppAlert.info(message: l10n.noDs160Warning),
              ],

              SizedBox(height: AppTheme.espacioAntesBotonPrincipal),

              // Action Button
              SizedBox(
                height: AppTheme.alturaBotonGrande,
                child: ElevatedButton(
                  onPressed: quickCheckState.isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.actionBlue,
                    foregroundColor: AppTheme.inkInverse,
                     shape: RoundedRectangleBorder(borderRadius: AppTheme.smallRadius),
                     elevation: AppTheme.elevacionNula,
                  ),
                  child: quickCheckState.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.inkInverse),
                          ),
                        )
                      : Text(
                          l10n.startAnalysis,
                          style: AppTheme.captionWhiteBold.copyWith(letterSpacing: 0.5),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_hasDs160 && !_formKey.currentState!.validate()) return;

    await ref.read(quickCheckNotifierProvider.notifier).saveQuickCheck(
      visaType: _selectedVisaType,
      ds160Code: _hasDs160 ? _ds160Controller.text : null,
      hasDs160: _hasDs160,
    );

    ref.invalidate(userApplicationProvider);

    if (mounted) {
      context.push('/risk-audit');
    }
  }
}

class _RadioOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioOption({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppTheme.smallRadius,
      child: Container(
        padding: AppTheme.paddingListItem,
        decoration: BoxDecoration(
          color: selected ? AppTheme.navyPrimary.withOpacity(0.05) : AppTheme.inkInverse,
          border: Border.all(
            color: selected ? AppTheme.navyPrimary : AppTheme.dividerGrey,
            width: selected ? 2 : 1
          ),
          borderRadius: AppTheme.smallRadius,
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppTheme.navyPrimary : AppTheme.inkSecondary,
              size: AppTheme.iconoMini,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: selected ? AppTheme.labelBold : AppTheme.labelRegular,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
