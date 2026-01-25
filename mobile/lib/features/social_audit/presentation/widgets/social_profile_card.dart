import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';

import '../../data/models/social_media_profile.dart';

/// Tarjeta de perfil de redes sociales
class SocialProfileCard extends StatelessWidget {
  final SocialMediaProfile profile;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAudit;

  const SocialProfileCard({
    super.key,
    required this.profile,
    this.onEdit,
    this.onDelete,
    this.onAudit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = _getAuditStatusColor(profile.auditStatus);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppTheme.cardRadius,
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: AppTheme.paddingEstandar,
            child: Row(
              children: [
                // Platform icon
                Container(
                  padding: AppTheme.paddingPequeno,
                  decoration: BoxDecoration(
                    color: _getPlatformColor(profile.platform).withOpacity(0.1),
                    borderRadius: AppTheme.inputRadius,
                  ),
                  child: Icon(
                    _getPlatformIcon(profile.platform),
                    color: _getPlatformColor(profile.platform),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Profile info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            profile.platform.displayName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(theme, profile.auditStatus, statusColor),
                        ],
                      ),
                      SizedBox(height: AppTheme.espacioEntreLabelInput),
                      if (profile.username != null)
                        Text(
                          '@${profile.username}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      Text(
                        profile.profileUrl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions menu
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                      case 'audit':
                        onAudit?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'audit',
                      child: Row(
                        children: [
                          Icon(Icons.verified_user),
                          SizedBox(width: 8),
                          Text('Run Audit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: AppTheme.errorRed),
                          const SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: AppTheme.labelRegular.copyWith(color: AppTheme.errorRed),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Discrepancies if any
          if (profile.hasDiscrepancies && profile.discrepancyDetails != null) ...[
            const Divider(height: 1),
            Container(
              padding: AppTheme.paddingEstandar,
              decoration: BoxDecoration(
                color: AppTheme.warningOrange.withOpacity(0.05),
                borderRadius: BorderRadius.only(
                  bottomLeft: AppTheme.radiusTarjetaEsquina,
                  bottomRight: AppTheme.radiusTarjetaEsquina,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: AppTheme.warningOrange,
                        size: AppTheme.iconoEnTarjeta,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Discrepancies Detected',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.warningOrange,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.espacioEntreCampos),
                  ...(_getDiscrepancyMessages(profile.discrepancyDetails!)
                      .map((msg) => Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• '),
                                Expanded(
                                  child: Text(
                                    msg,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppTheme.warningOrange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, AuditStatus status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppTheme.inputRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusLabel(status),
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(AuditStatus status) {
    switch (status) {
      case AuditStatus.pending:
        return 'Pending';
      case AuditStatus.matched:
        return 'Verified';
      case AuditStatus.discrepancy:
        return 'Mismatch';
      case AuditStatus.alert:
        return 'Alert';
    }
  }

  Color _getAuditStatusColor(AuditStatus status) {
    switch (status) {
      case AuditStatus.pending:
        return AppTheme.dividerGrey;
      case AuditStatus.matched:
        return AppTheme.successGreen;
      case AuditStatus.discrepancy:
        return AppTheme.warningOrange;
      case AuditStatus.alert:
        return AppTheme.errorRed;
    }
  }

  Color _getPlatformColor(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.linkedin:
        return AppTheme.linkedinBlue;
      case SocialPlatform.facebook:
        return AppTheme.facebookBlue;
      case SocialPlatform.instagram:
        return AppTheme.instagramPink;
      case SocialPlatform.twitter:
        return AppTheme.inkPrimary;
      case SocialPlatform.tiktok:
        return AppTheme.inkPrimary;
      case SocialPlatform.other:
        return AppTheme.dividerGrey;
    }
  }

  IconData _getPlatformIcon(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.linkedin:
        return Icons.business;
      case SocialPlatform.facebook:
        return Icons.facebook;
      case SocialPlatform.instagram:
        return Icons.camera_alt;
      case SocialPlatform.twitter:
        return Icons.alternate_email;
      case SocialPlatform.tiktok:
        return Icons.music_video;
      case SocialPlatform.other:
        return Icons.link;
    }
  }

  List<String> _getDiscrepancyMessages(Map<String, dynamic> details) {
    final messages = <String>[];
    
    if (details.containsKey('discrepancies')) {
      final discrepancies = details['discrepancies'] as List<dynamic>?;
      if (discrepancies != null) {
        for (final d in discrepancies) {
          if (d is Map<String, dynamic> && d.containsKey('message')) {
            messages.add(d['message'] as String);
          }
        }
      }
    }
    
    return messages.isEmpty
        ? ['Employment history does not match DS-160 declaration']
        : messages;
  }
}

/// Widget para agregar perfil de redes sociales
class AddSocialProfileSheet extends StatefulWidget {
  final void Function(SocialPlatform platform, String url, String? username) onAdd;

  const AddSocialProfileSheet({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddSocialProfileSheet> createState() => _AddSocialProfileSheetState();
}

class _AddSocialProfileSheetState extends State<AddSocialProfileSheet> {
  SocialPlatform? _selectedPlatform;
  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _urlController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.inkSecondary,
                  borderRadius: AppTheme.smallRadius,
                ),
              ),
            ),
            SizedBox(height: AppTheme.espacioEntreCards),
            Text(
              'Add Social Media Profile',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppTheme.espacioEntreCampos),
            Text(
              'DS-160 requires disclosure of social media accounts used in the last 5 years.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppTheme.espacioEntreCards),

            // Platform selector
            Text(
              'Platform',
              style: theme.textTheme.labelLarge,
            ),
            SizedBox(height: AppTheme.espacioEntreCampos),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SocialPlatform.values
                  .where((p) => p != SocialPlatform.other)
                  .map((platform) => _buildPlatformChip(platform))
                  .toList(),
            ),

            const SizedBox(height: 20),

            // URL field
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Profile URL',
                hintText: 'https://linkedin.com/in/username',
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: AppTheme.inputRadius,
                ),
              ),
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Profile URL is required';
                }
                if (!Uri.tryParse(value)!.hasAbsolutePath) {
                  return 'Enter a valid URL';
                }
                return null;
              },
            ),

            SizedBox(height: AppTheme.espacioEntreSecciones),

            // Username field
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username (optional)',
                hintText: '@username',
                prefixIcon: const Icon(Icons.alternate_email),
                border: OutlineInputBorder(
                  borderRadius: AppTheme.inputRadius,
                ),
              ),
            ),

            SizedBox(height: AppTheme.espacioEntreCards),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: AppTheme.alturaBotonGrande,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.add),
                label: const Text('Add Profile'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.inputRadius,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformChip(SocialPlatform platform) {
    final isSelected = _selectedPlatform == platform;

    return FilterChip(
      selected: isSelected,
      label: Text(platform.displayName),
      avatar: Icon(
        _getPlatformIcon(platform),
        size: AppTheme.iconoMini,
      ),
      onSelected: (selected) {
        setState(() {
          _selectedPlatform = selected ? platform : null;
        });
      },
    );
  }

  IconData _getPlatformIcon(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.linkedin:
        return Icons.business;
      case SocialPlatform.facebook:
        return Icons.facebook;
      case SocialPlatform.instagram:
        return Icons.camera_alt;
      case SocialPlatform.twitter:
        return Icons.alternate_email;
      case SocialPlatform.tiktok:
        return Icons.music_video;
      case SocialPlatform.other:
        return Icons.link;
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedPlatform == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a platform'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      widget.onAdd(
        _selectedPlatform!,
        _urlController.text,
        _usernameController.text.isNotEmpty ? _usernameController.text : null,
      );
      Navigator.pop(context);
    }
  }
}
