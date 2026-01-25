import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_header.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';

/// Register screen with full i18n support and consistent design.
/// Updated: 2026-01-21 - Applied i18n and AppHeader per audit requirements
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).signUp(
            _emailController.text,
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final l10n = context.l10n;

    ref.listen(authProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.error(next.error.toString()))),
        );
      } else if (!next.isLoading && next.hasValue) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.accountCreated)),
        );
      }
    });

    return Scaffold(
      appBar: AppHeader(title: l10n.registerTitle),
      body: Padding(
        padding: AppTheme.paddingGrande,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                 Image.asset('assets/images/logo.png', height: 60),
                 SizedBox(height: AppTheme.espacioEntreCards),
                 
                 Card(
                  elevation: AppTheme.elevacionBaja,
                  shape: RoundedRectangleBorder(borderRadius: AppTheme.smallRadius),
                  child: Padding(
                    padding: AppTheme.paddingGrande,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                           Text(
                            l10n.registerTitle,
                            style: AppTheme.h1NavyBold,
                          ),
                          SizedBox(height: AppTheme.espacioEntreCards),
                          
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(labelText: l10n.emailLabel),
                            validator: (value) {
                              if (value == null || value.isEmpty) return l10n.fieldRequired;
                              if (!value.contains('@')) return l10n.emailInvalid;
                              return null;
                            },
                          ),
                          SizedBox(height: AppTheme.espacioEntreSecciones),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(labelText: l10n.passwordLabel),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) return l10n.fieldRequired;
                              if (value.length < 6) return l10n.passwordMinLength(6);
                              return null;
                            },
                          ),
                           SizedBox(height: AppTheme.espacioEntreSecciones),
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(labelText: l10n.confirmPasswordLabel),
                            obscureText: true,
                            validator: (value) {
                              if (value != _passwordController.text) return l10n.passwordsDoNotMatch;
                              return null;
                            },
                          ),
                          SizedBox(height: AppTheme.espacioEntreCards),
                          if (isLoading)
                            const CircularProgressIndicator()
                          else
                            Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _submit,
                                    child: Text(l10n.registerButton),
                                  ),
                                ),
                                SizedBox(height: AppTheme.espacioEntreSecciones),
                                TextButton(
                                  onPressed: () => context.pop(),
                                  child: Text(l10n.alreadyHaveAccount),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
