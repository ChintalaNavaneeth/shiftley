// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryImpl _$$CategoryImplFromJson(Map<String, dynamic> json) =>
    _$CategoryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool,
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => Skill.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CategoryImplToJson(_$CategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'is_active': instance.isActive,
      'skills': instance.skills,
    };

_$SkillImpl _$$SkillImplFromJson(Map<String, dynamic> json) => _$SkillImpl(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool,
    );

Map<String, dynamic> _$$SkillImplToJson(_$SkillImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category_id': instance.categoryId,
      'name': instance.name,
      'is_active': instance.isActive,
    };

_$ManagementUserImpl _$$ManagementUserImplFromJson(Map<String, dynamic> json) =>
    _$ManagementUserImpl(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$ManagementUserImplToJson(
        _$ManagementUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'role': instance.role,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
    };

_$PlatformConfigImpl _$$PlatformConfigImplFromJson(Map<String, dynamic> json) =>
    _$PlatformConfigImpl(
      employerSubscriptionMonthly:
          (json['employer_subscription_monthly'] as num).toDouble(),
      employerSubscriptionWeekly:
          (json['employer_subscription_weekly'] as num).toDouble(),
      employerSubscriptionDaily:
          (json['employer_subscription_daily'] as num).toDouble(),
      workerNoShowPenalty: (json['worker_no_show_penalty'] as num).toDouble(),
      employerCancelPenalty6h:
          (json['employer_cancel_penalty_6h'] as num).toDouble(),
      employerCancelPenalty3h:
          (json['employer_cancel_penalty_3h'] as num).toDouble(),
      employerCancelPenalty1h:
          (json['employer_cancel_penalty_1h'] as num).toDouble(),
    );

Map<String, dynamic> _$$PlatformConfigImplToJson(
        _$PlatformConfigImpl instance) =>
    <String, dynamic>{
      'employer_subscription_monthly': instance.employerSubscriptionMonthly,
      'employer_subscription_weekly': instance.employerSubscriptionWeekly,
      'employer_subscription_daily': instance.employerSubscriptionDaily,
      'worker_no_show_penalty': instance.workerNoShowPenalty,
      'employer_cancel_penalty_6h': instance.employerCancelPenalty6h,
      'employer_cancel_penalty_3h': instance.employerCancelPenalty3h,
      'employer_cancel_penalty_1h': instance.employerCancelPenalty1h,
    };

_$DisputeImpl _$$DisputeImplFromJson(Map<String, dynamic> json) =>
    _$DisputeImpl(
      id: json['id'] as String,
      gigId: json['gig_id'] as String,
      workerName: json['worker_name'] as String,
      businessName: json['business_name'] as String,
      amountPaise: (json['amount_paise'] as num).toInt(),
      reason: json['reason'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      resolution: json['resolution'] as String?,
    );

Map<String, dynamic> _$$DisputeImplToJson(_$DisputeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gig_id': instance.gigId,
      'worker_name': instance.workerName,
      'business_name': instance.businessName,
      'amount_paise': instance.amountPaise,
      'reason': instance.reason,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'resolution': instance.resolution,
    };

_$AnalyticsOverviewImpl _$$AnalyticsOverviewImplFromJson(
        Map<String, dynamic> json) =>
    _$AnalyticsOverviewImpl(
      totalGigs: (json['total_gigs'] as num).toInt(),
      activeWorkers: (json['active_workers'] as num).toInt(),
      activeBusinesses: (json['active_businesses'] as num).toInt(),
      totalRevenuePaise: (json['total_revenue_paise'] as num).toInt(),
    );

Map<String, dynamic> _$$AnalyticsOverviewImplToJson(
        _$AnalyticsOverviewImpl instance) =>
    <String, dynamic>{
      'total_gigs': instance.totalGigs,
      'active_workers': instance.activeWorkers,
      'active_businesses': instance.activeBusinesses,
      'total_revenue_paise': instance.totalRevenuePaise,
    };

_$FinancialMetricsImpl _$$FinancialMetricsImplFromJson(
        Map<String, dynamic> json) =>
    _$FinancialMetricsImpl(
      escrowBalancePaise: (json['escrow_balance_paise'] as num).toInt(),
      totalPayoutsPaise: (json['total_payouts_paise'] as num).toInt(),
      commissionEarnedPaise: (json['commission_earned_paise'] as num).toInt(),
    );

Map<String, dynamic> _$$FinancialMetricsImplToJson(
        _$FinancialMetricsImpl instance) =>
    <String, dynamic>{
      'escrow_balance_paise': instance.escrowBalancePaise,
      'total_payouts_paise': instance.totalPayoutsPaise,
      'commission_earned_paise': instance.commissionEarnedPaise,
    };

_$ExpenditureImpl _$$ExpenditureImplFromJson(Map<String, dynamic> json) =>
    _$ExpenditureImpl(
      id: json['id'] as String,
      type: json['type'] as String,
      amountPaise: (json['amount_paise'] as num).toInt(),
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$ExpenditureImplToJson(_$ExpenditureImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount_paise': instance.amountPaise,
      'description': instance.description,
      'created_at': instance.createdAt.toIso8601String(),
    };
