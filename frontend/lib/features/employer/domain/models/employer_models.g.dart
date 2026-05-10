// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employer_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployerProfile _$EmployerProfileFromJson(Map<String, dynamic> json) =>
    EmployerProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      businessName: json['business_name'] as String,
      businessType: json['business_type'] as String,
      gstNumber: json['gst_number'] as String?,
      businessAddress: json['business_address'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      verificationStatus: json['verification_status'] as String,
      aadhaarLast4: json['aadhaar_last_4'] as String?,
      photoUrls: (json['photo_urls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$EmployerProfileToJson(EmployerProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'business_name': instance.businessName,
      'business_type': instance.businessType,
      'gst_number': instance.gstNumber,
      'business_address': instance.businessAddress,
      'lat': instance.lat,
      'lng': instance.lng,
      'verification_status': instance.verificationStatus,
      'aadhaar_last_4': instance.aadhaarLast4,
      'photo_urls': instance.photoUrls,
    };

EmployerStats _$EmployerStatsFromJson(Map<String, dynamic> json) =>
    EmployerStats(
      totalGigsPosted: (json['total_gigs_posted'] as num).toInt(),
      activePlan: json['active_plan'] as String,
      planExpiresAt: json['plan_expires_at'] == null
          ? null
          : DateTime.parse(json['plan_expires_at'] as String),
      freeGigsRemaining: (json['free_gigs_remaining'] as num).toInt(),
    );

Map<String, dynamic> _$EmployerStatsToJson(EmployerStats instance) =>
    <String, dynamic>{
      'total_gigs_posted': instance.totalGigsPosted,
      'active_plan': instance.activePlan,
      'plan_expires_at': instance.planExpiresAt?.toIso8601String(),
      'free_gigs_remaining': instance.freeGigsRemaining,
    };

EmployerDashboardData _$EmployerDashboardDataFromJson(
        Map<String, dynamic> json) =>
    EmployerDashboardData(
      profile:
          EmployerProfile.fromJson(json['profile'] as Map<String, dynamic>),
      stats: EmployerStats.fromJson(json['stats'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EmployerDashboardDataToJson(
        EmployerDashboardData instance) =>
    <String, dynamic>{
      'profile': instance.profile,
      'stats': instance.stats,
    };
