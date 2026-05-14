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
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'Employer',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      verificationStatus: json['verification_status'] as String,
      aadhaarLast4: json['aadhaar_last_4'] as String?,
      aadhaarUrl: json['aadhaar_url'] as String?,
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
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'full_name': instance.fullName,
      'lat': instance.lat,
      'lng': instance.lng,
      'verification_status': instance.verificationStatus,
      'aadhaar_last_4': instance.aadhaarLast4,
      'aadhaar_url': instance.aadhaarUrl,
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

SubscriptionPlanMeta _$SubscriptionPlanMetaFromJson(
        Map<String, dynamic> json) =>
    SubscriptionPlanMeta(
      id: json['id'] as String,
      name: json['name'] as String,
      pricePaise: (json['price_paise'] as num).toInt(),
      durationDays: (json['duration_days'] as num).toInt(),
      maxGigs: (json['max_gigs'] as num).toInt(),
      maxEmployeesPerGig: (json['max_employees_per_gig'] as num).toInt(),
    );

Map<String, dynamic> _$SubscriptionPlanMetaToJson(
        SubscriptionPlanMeta instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price_paise': instance.pricePaise,
      'duration_days': instance.durationDays,
      'max_gigs': instance.maxGigs,
      'max_employees_per_gig': instance.maxEmployeesPerGig,
    };

PlatformConfig _$PlatformConfigFromJson(Map<String, dynamic> json) =>
    PlatformConfig(
      workerNoShowPenalty: (json['worker_no_show_penalty'] as num?)?.toDouble(),
      employerCancelPenalty6h:
          (json['employer_cancel_penalty_6h'] as num?)?.toDouble(),
      employerCancelPenalty3h:
          (json['employer_cancel_penalty_3h'] as num?)?.toDouble(),
      employerCancelPenalty1h:
          (json['employer_cancel_penalty_1h'] as num?)?.toDouble(),
      employerCancelBaseFine:
          (json['employer_cancel_base_fine'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PlatformConfigToJson(PlatformConfig instance) =>
    <String, dynamic>{
      'worker_no_show_penalty': instance.workerNoShowPenalty,
      'employer_cancel_penalty_6h': instance.employerCancelPenalty6h,
      'employer_cancel_penalty_3h': instance.employerCancelPenalty3h,
      'employer_cancel_penalty_1h': instance.employerCancelPenalty1h,
      'employer_cancel_base_fine': instance.employerCancelBaseFine,
    };

EmployerDashboardData _$EmployerDashboardDataFromJson(
        Map<String, dynamic> json) =>
    EmployerDashboardData(
      profile:
          EmployerProfile.fromJson(json['profile'] as Map<String, dynamic>),
      stats: EmployerStats.fromJson(json['stats'] as Map<String, dynamic>),
      availablePlans: (json['available_plans'] as List<dynamic>?)
              ?.map((e) =>
                  SubscriptionPlanMeta.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      config: json['config'] == null
          ? null
          : PlatformConfig.fromJson(json['config'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EmployerDashboardDataToJson(
        EmployerDashboardData instance) =>
    <String, dynamic>{
      'profile': instance.profile,
      'stats': instance.stats,
      'available_plans': instance.availablePlans,
      'config': instance.config,
    };
