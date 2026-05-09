// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryImpl _$$CategoryImplFromJson(Map<String, dynamic> json) =>
    _$CategoryImpl(
      id: json['id'] as String,
      name: json['name'] as String?,
      isActive: json['is_active'] as bool? ?? true,
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
      categoryId: json['category_id'] as String?,
      name: json['name'] as String?,
      isActive: json['is_active'] as bool? ?? true,
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
      totalGigs: (json['gigs_posted'] as num?)?.toInt() ?? 0,
      activeWorkers: (json['total_active_workers'] as num?)?.toInt() ?? 0,
      activeBusinesses:
          (json['total_verified_employers'] as num?)?.toInt() ?? 0,
      completedGigs: (json['gigs_completed'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$AnalyticsOverviewImplToJson(
        _$AnalyticsOverviewImpl instance) =>
    <String, dynamic>{
      'gigs_posted': instance.totalGigs,
      'total_active_workers': instance.activeWorkers,
      'total_verified_employers': instance.activeBusinesses,
      'gigs_completed': instance.completedGigs,
    };

_$FinancialMetricsImpl _$$FinancialMetricsImplFromJson(
        Map<String, dynamic> json) =>
    _$FinancialMetricsImpl(
      escrowBalancePaise:
          (json['current_escrow_load_paise'] as num?)?.toInt() ?? 0,
      subscriptionRevenuePaise:
          (json['subscription_revenue_paise'] as num?)?.toInt() ?? 0,
      fineRevenuePaise:
          (json['retained_cancellation_fines_paise'] as num?)?.toInt() ?? 0,
      totalWorkerGmvPaise:
          (json['total_worker_gmv_paise'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$FinancialMetricsImplToJson(
        _$FinancialMetricsImpl instance) =>
    <String, dynamic>{
      'current_escrow_load_paise': instance.escrowBalancePaise,
      'subscription_revenue_paise': instance.subscriptionRevenuePaise,
      'retained_cancellation_fines_paise': instance.fineRevenuePaise,
      'total_worker_gmv_paise': instance.totalWorkerGmvPaise,
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

_$PnLSummaryImpl _$$PnLSummaryImplFromJson(Map<String, dynamic> json) =>
    _$PnLSummaryImpl(
      month: json['month'] as String,
      grossRevenue: json['gross_revenue'] as Map<String, dynamic>? ?? const {},
      expenditures: json['expenditures'] as Map<String, dynamic>? ?? const {},
      netProfitPaise: (json['net_profit_paise'] as num?)?.toInt() ?? 0,
      profitMarginPercentage:
          (json['profit_margin_percentage'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$PnLSummaryImplToJson(_$PnLSummaryImpl instance) =>
    <String, dynamic>{
      'month': instance.month,
      'gross_revenue': instance.grossRevenue,
      'expenditures': instance.expenditures,
      'net_profit_paise': instance.netProfitPaise,
      'profit_margin_percentage': instance.profitMarginPercentage,
    };

_$LiquidityMetricsImpl _$$LiquidityMetricsImplFromJson(
        Map<String, dynamic> json) =>
    _$LiquidityMetricsImpl(
      fillRate: (json['gig_fill_rate_percentage'] as num).toDouble(),
      workerRatio: (json['worker_to_gig_ratio'] as num).toDouble(),
      topSkill: json['most_demanded_skill'] as String,
    );

Map<String, dynamic> _$$LiquidityMetricsImplToJson(
        _$LiquidityMetricsImpl instance) =>
    <String, dynamic>{
      'gig_fill_rate_percentage': instance.fillRate,
      'worker_to_gig_ratio': instance.workerRatio,
      'most_demanded_skill': instance.topSkill,
    };

_$PlatformHealthImpl _$$PlatformHealthImplFromJson(Map<String, dynamic> json) =>
    _$PlatformHealthImpl(
      noShowRate: (json['no_show_rate_percentage'] as num).toDouble(),
      emergencyRate:
          (json['emergency_trigger_rate_percentage'] as num).toDouble(),
      slaBreaches: (json['verifier_sla_breaches'] as num).toInt(),
    );

Map<String, dynamic> _$$PlatformHealthImplToJson(
        _$PlatformHealthImpl instance) =>
    <String, dynamic>{
      'no_show_rate_percentage': instance.noShowRate,
      'emergency_trigger_rate_percentage': instance.emergencyRate,
      'verifier_sla_breaches': instance.slaBreaches,
    };
