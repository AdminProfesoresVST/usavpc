/// Perfil de redes sociales para auditoría
/// Fuente: Supabase table `social_media_profiles`
class SocialMediaProfile {
  final String id;
  final String applicationId;
  final SocialPlatform platform;
  final String profileUrl;
  final String? username;
  final bool last5Years;
  final Map<String, dynamic>? employmentData;
  final AuditStatus auditStatus;
  final Map<String, dynamic>? discrepancyDetails;
  final DateTime createdAt;
  final DateTime? auditedAt;

  SocialMediaProfile({
    required this.id,
    required this.applicationId,
    required this.platform,
    required this.profileUrl,
    this.username,
    this.last5Years = true,
    this.employmentData,
    this.auditStatus = AuditStatus.pending,
    this.discrepancyDetails,
    required this.createdAt,
    this.auditedAt,
  })  : assert(id.isNotEmpty, 'SocialMediaProfile ID cannot be empty'),
        assert(profileUrl.isNotEmpty, 'Profile URL cannot be empty');

  factory SocialMediaProfile.fromJson(Map<String, dynamic> json) {
    return SocialMediaProfile(
      id: json['id'] as String,
      applicationId: json['application_id'] as String,
      platform: SocialPlatform.fromString(json['platform'] as String),
      profileUrl: json['profile_url'] as String,
      username: json['username'] as String?,
      last5Years: json['last_5_years'] as bool? ?? true,
      employmentData: json['employment_data'] != null
          ? Map<String, dynamic>.from(json['employment_data'] as Map)
          : null,
      auditStatus: AuditStatus.fromString(json['audit_status'] as String),
      discrepancyDetails: json['discrepancy_details'] != null
          ? Map<String, dynamic>.from(json['discrepancy_details'] as Map)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      auditedAt: json['audited_at'] != null
          ? DateTime.parse(json['audited_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'application_id': applicationId,
      'platform': platform.value,
      'profile_url': profileUrl,
      'username': username,
      'last_5_years': last5Years,
      'employment_data': employmentData,
      'audit_status': auditStatus.value,
      'discrepancy_details': discrepancyDetails,
      'created_at': createdAt.toIso8601String(),
      'audited_at': auditedAt?.toIso8601String(),
    };
  }

  /// Verifica si hay discrepancias detectadas
  bool get hasDiscrepancies =>
      auditStatus == AuditStatus.discrepancy ||
      auditStatus == AuditStatus.alert;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SocialMediaProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Plataformas de redes sociales
enum SocialPlatform {
  linkedin('linkedin'),
  facebook('facebook'),
  instagram('instagram'),
  twitter('twitter'),
  tiktok('tiktok'),
  other('other');

  final String value;
  const SocialPlatform(this.value);

  static SocialPlatform fromString(String value) {
    return SocialPlatform.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SocialPlatform.other,
    );
  }

  String get displayName {
    switch (this) {
      case SocialPlatform.linkedin:
        return 'LinkedIn';
      case SocialPlatform.facebook:
        return 'Facebook';
      case SocialPlatform.instagram:
        return 'Instagram';
      case SocialPlatform.twitter:
        return 'X (Twitter)';
      case SocialPlatform.tiktok:
        return 'TikTok';
      case SocialPlatform.other:
        return 'Other';
    }
  }

  String get iconAsset {
    switch (this) {
      case SocialPlatform.linkedin:
        return 'assets/icons/linkedin.svg';
      case SocialPlatform.facebook:
        return 'assets/icons/facebook.svg';
      case SocialPlatform.instagram:
        return 'assets/icons/instagram.svg';
      case SocialPlatform.twitter:
        return 'assets/icons/twitter.svg';
      case SocialPlatform.tiktok:
        return 'assets/icons/tiktok.svg';
      case SocialPlatform.other:
        return 'assets/icons/link.svg';
    }
  }
}

/// Estado de auditoría
enum AuditStatus {
  pending('pending'),
  matched('matched'),
  discrepancy('discrepancy'),
  alert('alert');

  final String value;
  const AuditStatus(this.value);

  static AuditStatus fromString(String value) {
    return AuditStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AuditStatus.pending,
    );
  }

  String get colorHex {
    switch (this) {
      case AuditStatus.pending:
        return '#9E9E9E'; // Grey
      case AuditStatus.matched:
        return '#4CAF50'; // Green
      case AuditStatus.discrepancy:
        return '#FF9800'; // Orange
      case AuditStatus.alert:
        return '#F44336'; // Red
    }
  }
}

/// Discrepancia de empleo detectada
class EmploymentDiscrepancy {
  final String type;
  final Map<String, dynamic>? ds160Data;
  final Map<String, dynamic>? socialData;
  final String message;

  const EmploymentDiscrepancy({
    required this.type,
    this.ds160Data,
    this.socialData,
    required this.message,
  });

  factory EmploymentDiscrepancy.fromJson(Map<String, dynamic> json) {
    return EmploymentDiscrepancy(
      type: json['type'] as String,
      ds160Data: json['ds160_data'] != null
          ? Map<String, dynamic>.from(json['ds160_data'] as Map)
          : null,
      socialData: json['social_data'] != null
          ? Map<String, dynamic>.from(json['social_data'] as Map)
          : null,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'ds160_data': ds160Data,
      'social_data': socialData,
      'message': message,
    };
  }
}
