import 'package:json_annotation/json_annotation.dart';

part 'verifier_models.g.dart';

@JsonSerializable()
class QueueItem {
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String email;
  final String role;
  @JsonKey(name: 'kyc_status')
  final String kycStatus;
  @JsonKey(name: 'masked_aadhaar')
  final String maskedAadhaar;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  QueueItem({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.kycStatus,
    required this.maskedAadhaar,
    required this.createdAt,
  });

  factory QueueItem.fromJson(Map<String, dynamic> json) => _$QueueItemFromJson(json);
  Map<String, dynamic> toJson() => _$QueueItemToJson(this);
}

@JsonSerializable()
class VerificationAudit {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'verifier_id')
  final String verifierId;
  final String status;
  final String notes;
  @JsonKey(name: 'verifier_selfie_url')
  final String? verifierSelfieUrl;
  @JsonKey(name: 'location_photo_1_url')
  final String? locationPhoto1Url;
  @JsonKey(name: 'verified_lat')
  final double? verifiedLat;
  @JsonKey(name: 'verified_lng')
  final double? verifiedLng;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  VerificationAudit({
    required this.id,
    required this.userId,
    required this.verifierId,
    required this.status,
    required this.notes,
    this.verifierSelfieUrl,
    this.locationPhoto1Url,
    this.verifiedLat,
    this.verifiedLng,
    required this.createdAt,
  });

  factory VerificationAudit.fromJson(Map<String, dynamic> json) => _$VerificationAuditFromJson(json);
  Map<String, dynamic> toJson() => _$VerificationAuditToJson(this);
}

@JsonSerializable()
class VerifierProfile {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'full_name')
  final String? fullName;
  final String? email;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  final String? role;
  @JsonKey(name: 'profile_photo_url')
  final String profilePhotoUrl;
  @JsonKey(name: 'aadhaar_url')
  final String aadhaarUrl;
  final double lat;
  final double lng;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  VerifierProfile({
    required this.id,
    required this.userId,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.role,
    required this.profilePhotoUrl,
    required this.aadhaarUrl,
    required this.lat,
    required this.lng,
    required this.createdAt,
  });

  factory VerifierProfile.fromJson(Map<String, dynamic> json) => _$VerifierProfileFromJson(json);
  Map<String, dynamic> toJson() => _$VerifierProfileToJson(this);
}
