// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verifier_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueueItem _$QueueItemFromJson(Map<String, dynamic> json) => QueueItem(
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      kycStatus: json['kyc_status'] as String,
      maskedAadhaar: json['masked_aadhaar'] as String,
      phoneNumber: json['phone_number'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$QueueItemToJson(QueueItem instance) => <String, dynamic>{
      'user_id': instance.userId,
      'full_name': instance.fullName,
      'email': instance.email,
      'role': instance.role,
      'kyc_status': instance.kycStatus,
      'masked_aadhaar': instance.maskedAadhaar,
      'phone_number': instance.phoneNumber,
      'created_at': instance.createdAt.toIso8601String(),
    };

VerificationAudit _$VerificationAuditFromJson(Map<String, dynamic> json) =>
    VerificationAudit(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userFullName: json['user_full_name'] as String?,
      verifierId: json['verifier_id'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String,
      verifierSelfieUrl: json['verifier_selfie_url'] as String?,
      locationPhoto1Url: json['location_photo_1_url'] as String?,
      verifiedLat: (json['verified_lat'] as num?)?.toDouble(),
      verifiedLng: (json['verified_lng'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$VerificationAuditToJson(VerificationAudit instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'user_full_name': instance.userFullName,
      'verifier_id': instance.verifierId,
      'status': instance.status,
      'notes': instance.notes,
      'verifier_selfie_url': instance.verifierSelfieUrl,
      'location_photo_1_url': instance.locationPhoto1Url,
      'verified_lat': instance.verifiedLat,
      'verified_lng': instance.verifiedLng,
      'created_at': instance.createdAt.toIso8601String(),
    };

VerifierProfile _$VerifierProfileFromJson(Map<String, dynamic> json) =>
    VerifierProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      role: json['role'] as String?,
      profilePhotoUrl: json['profile_photo_url'] as String,
      aadhaarUrl: json['aadhaar_url'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$VerifierProfileToJson(VerifierProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'full_name': instance.fullName,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'role': instance.role,
      'profile_photo_url': instance.profilePhotoUrl,
      'aadhaar_url': instance.aadhaarUrl,
      'lat': instance.lat,
      'lng': instance.lng,
      'created_at': instance.createdAt.toIso8601String(),
    };
