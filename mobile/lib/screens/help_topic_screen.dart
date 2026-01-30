import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_header.dart';

enum HelpTopic {
  scan,
  simulate,
  results,
}

class HelpTopicScreen extends StatelessWidget {
  final HelpTopic topic;

  const HelpTopicScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    // Dynamic Content based on Topic
    String title = '';
    String desc = '';
    List<String> bullets = [];
    String buttonText = '';
    VoidCallback onAction = () {};
    IconData icon = Icons.help;

    switch (topic) {
      case HelpTopic.scan:
        title = l10n.helpScanTitle;
        desc = l10n.helpScanDesc;
        bullets = [l10n.helpScanBullet1, l10n.helpScanBullet2];
        buttonText = l10n.helpScanButton;
        icon = Icons.document_scanner;
        onAction = () => context.go('/identity/start');
        break;
      case HelpTopic.simulate:
        title = l10n.helpSimulateTitle;
        desc = l10n.helpSimulateDesc;
        bullets = [l10n.helpSimulateBullet1, l10n.helpSimulateBullet2];
        buttonText = l10n.helpSimulateButton;
        icon = Icons.chat;
         // Logic to check auth before sim is handled in ServiceSelection, 
         // but here we can just go to sim intro or login
        onAction = () => context.go('/simulator'); 
        break;
      case HelpTopic.results:
        title = l10n.helpResultsTitle;
        desc = l10n.helpResultsDesc;
        bullets = [l10n.helpResultsBullet1, l10n.helpResultsBullet2];
        buttonText = l10n.helpResultsButton;
        icon = Icons.assignment_turned_in;
        onAction = () => context.pop(); // Go back to services
        break;
    }

    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      appBar: AppHeader(title: title),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: AppTheme.paddingExtraGrande,
                child: Column(
                  children: [
                    // 1. Hero Icon
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.navyPrimary.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 80, color: AppTheme.navyPrimary),
                    ),
                    const SizedBox(height: 32),
                    
                    // 2. Title & Desc
                    Text(
                      title,
                      style: AppTheme.h1NavyBold.copyWith(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      desc,
                      style: AppTheme.bodyPrimaryRegular.copyWith(height: 1.5, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // 3. Bullets
                    ...bullets.map((bullet) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle, color: AppTheme.successGreen, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              bullet,
                              style: AppTheme.bodyPrimaryRegular,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
            
            // 4. Action Button
            Container(
              padding: AppTheme.paddingEstandar,
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: AppTheme.alturaBotonGrande, // 50 in new theme but 35 in legacy? Checking AppTheme
                // Audit says 35, checking user preference for Big Buttons. 
                // Wait, AppTheme.alturaBotonGrande is 35. That's small.
                // But following Zero Tolerance, I must use the token.
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.navyPrimary,
                    foregroundColor: AppTheme.inkInverse,
                    shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius),
                    elevation: 0,
                  ),
                  child: Text(
                    buttonText,
                    style: AppTheme.h2WhiteBold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
