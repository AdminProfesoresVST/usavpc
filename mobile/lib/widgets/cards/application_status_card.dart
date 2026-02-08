import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';


import 'package:mobile/models/user_document.dart'; // [FIX] Import DocumentProgress

class ApplicationStatusCard extends StatelessWidget {
  final String status;
  final DocumentProgress? progress;
  final String? lastEdited; // [FIX] Change to String to match DashboardData

  const ApplicationStatusCard({
    super.key,
    required this.status,
    this.progress,
    this.lastEdited,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    // Determine real status based on document progress if available
    final isDocsEmpty = (progress?.totalUploaded ?? 0) == 0;
    
    // If we have 0 documents, we FORCE the status to be "Upload Required" visual
    final effectiveStatus = isDocsEmpty ? 'DocumentUploadRequired' : status;
    
    final statusConfig = _getStatusConfig(effectiveStatus, progress?.progressPercentage ?? 0.0, l10n);

    // [VISUAL UPDATE] Matching "Required Documents" Card Style (Light Theme)
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.navyPrimary.withValues(alpha: 0.05), // Light BG matches doc list
        borderRadius: AppTheme.cardRadius,
        border: Border.all(color: AppTheme.navyPrimary.withValues(alpha: 0.2)), // Subtle border
      ),
      child: Stack(
        children: [
          // Background graphic (Subtle Navy Icon)
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.verified_user_outlined,
              size: 150,
              color: AppTheme.navyPrimary.withValues(alpha: 0.05), // Very subtle navy
            ),
          ),
          
          Padding(
            padding: AppTheme.paddingEstandar,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.applicationStatus.toUpperCase(),
                          style: AppTheme.labelBold.copyWith(
                            letterSpacing: 1.2,
                            color: AppTheme.navyPrimary.withValues(alpha: 0.7), // Navy Label
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          statusConfig.label ?? _translateStatus(status, l10n),
                          style: AppTheme.h2NavyBold.copyWith(fontSize: 20), // Navy Title
                        ),
                      ],
                    ),
                    _buildStatusBadge(statusConfig.color, statusConfig.icon),
                  ],
                ),
                
                SizedBox(height: AppTheme.espacioEntreSecciones),
                
                // Progress Section
                if (progress != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${progress!.totalUploaded} / ${progress!.totalRequired} ${l10n.documentsScanned}', 
                        style: AppTheme.bodyPrimaryRegular.copyWith(
                            color: AppTheme.navyPrimary.withValues(alpha: 0.8),
                            fontSize: 13
                        ),
                      ),
                      Text(
                        '${(progress!.progressPercentage * 100).toInt()}%',
                        style: AppTheme.h2NavyBold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress!.progressPercentage.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: AppTheme.softBlue, // Matching doc list style
                      valueColor: AlwaysStoppedAnimation<Color>(statusConfig.barColor),
                    ),
                  ),
                ],

                if (lastEdited != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.history, size: 14, color: AppTheme.inkSecondary),
                      const SizedBox(width: 4),
                      Text(
                        l10n.lastEdited(lastEdited!),
                        style: AppTheme.captionGreyRegular.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1), // Light tint
        shape: BoxShape.circle,
        border: Border.all(
            color: color.withValues(alpha: 0.3), // Colored border
            width: 1.5
        ),
      ),
      child: Icon(
        icon, 
        color: color, // Icon takes text color now (Navy/Blue)
        size: 24,
      ),
    );
  }

  ({Color color, Color barColor, IconData icon, String? label}) _getStatusConfig(String status, double progress, dynamic l10n) {
    // [STRICT VISUAL COMPLIANCE]
    
    if (status == 'DocumentUploadRequired') {
       return (
        color: AppTheme.actionBlue, 
        barColor: AppTheme.actionBlue,
        icon: Icons.upload_file,
        label: l10n.uploadRequired
      );
    }

    switch (status.toUpperCase()) {
      case 'PAID':
      case 'SUBMITTED':
      case 'COMPLETE':
        return (
          color: AppTheme.navyPrimary, 
          barColor: AppTheme.navyPrimary,
          icon: Icons.check_circle,
          label: null
        );
      case 'REJECTED':
      case 'DENIED':
        return (
          color: AppTheme.navyPrimary, 
          barColor: AppTheme.navyPrimary,
          icon: Icons.cancel,
          label: null
        );
      case 'OCR_COMPLETE':
      case 'VERIFIED':
      case 'SCANNING_DONE':
        return (
          color: AppTheme.actionBlue, 
          barColor: AppTheme.actionBlue,
          icon: Icons.verified,
          label: null
        );
      case 'PENDING_PAYMENT':
      case 'AWAITING':
        return (
          color: AppTheme.actionBlue, 
          barColor: AppTheme.actionBlue,
          icon: Icons.credit_card,
          label: null
        );
      default:
        final barColor = progress > 0.5 ? AppTheme.actionBlue : AppTheme.softBlue;
        return (
          color: AppTheme.softBlue, 
          barColor: barColor, 
          icon: Icons.edit_note, 
          label: null
        );
    }
  }

  String _translateStatus(String status, dynamic l10n) {
     switch (status.toUpperCase()) {
      case 'DRAFT': return l10n.statusDraft;
      case 'PENDING_PAYMENT': return l10n.statusPendingPayment;
      case 'PAID': return l10n.statusPaid;
      case 'SUBMITTED': return l10n.statusSubmitted;
      case 'NOT_STARTED': return l10n.statusNotStarted;
      case 'OCR_COMPLETE': return l10n.statusDocumentsScanned;
      case 'VERIFIED': return l10n.statusVerified;
      case 'IN_PROGRESS': return l10n.statusInProgress;
      case 'COMPLETE': return l10n.statusComplete;
      case 'REJECTED': return l10n.statusRejected;
      case 'DENIED': return l10n.statusDenied;
      default: return l10n.statusInProgress;
    }
  }
}
