import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_header.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';

/// Login screen with full i18n support and consistent design.
/// Updated: 2026-01-21 - Applied i18n and AppHeader per audit requirements
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).signIn(
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
      }
    });

    return Scaffold(
      appBar: AppHeader(title: l10n.loginTitle),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo & Title
               Image.asset('assets/images/logo.png', height: 80),
               const SizedBox(height: 16),
               Text(
                l10n.loginAppName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.navyPrimary,
                ),
              ),
              const SizedBox(height: 32),
              
              // Form Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: AppTheme.smallRadius),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          key: const Key('emailField'),
                          decoration: InputDecoration(labelText: l10n.emailLabel),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.emailRequired;
                            }
                            if (!value.contains('@')) {
                              return l10n.emailInvalid;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          key: const Key('passwordField'),
                          decoration: InputDecoration(labelText: l10n.passwordLabel),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.passwordRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        if (isLoading)
                          const CircularProgressIndicator()
                        else
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submit,
                              child: Text(l10n.loginButton),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => GoRouter.of(context).push('/register'),
                            child: Text(l10n.createAccountLink),
                          ),
                          const Divider(),
                          // SECURITY: Only show test credentials in debug mode
                          if (kDebugMode)
                            TextButton.icon(
                              icon: const Icon(Icons.developer_mode),
                              label: Text(l10n.quickFillTest),
                              onPressed: () {
                                _emailController.text = 'dev_applicant@gmail.com';
                                _passwordController.text = 'password';
                              },
                            ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              Text(
                l10n.nonGovernmentDisclaimer,
                style: AppTheme.captionGreyRegular,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
