import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_models.freezed.dart';
part 'admin_models.g.dart';

@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    String? name,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @Default([]) List<Skill> skills,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
}

@freezed
class Skill with _$Skill {
  const factory Skill({
    required String id,
    @JsonKey(name: 'category_id') String? categoryId,
    String? name,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _Skill;

  factory Skill.fromJson(Map<String, dynamic> json) => _$SkillFromJson(json);
}

@freezed
class ManagementUser with _$ManagementUser {
  const factory ManagementUser({
    required String id,
    @JsonKey(name: 'full_name') required String fullName,
    required String email,
    @JsonKey(name: 'phone_number') required String phoneNumber,
    required String role,
    required String status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ManagementUser;

  factory ManagementUser.fromJson(Map<String, dynamic> json) => _$ManagementUserFromJson(json);
}

@freezed
class PlatformConfig with _$PlatformConfig {
  const factory PlatformConfig({
    @JsonKey(name: 'employer_subscription_monthly') required double employerSubscriptionMonthly,
    @JsonKey(name: 'employer_subscription_weekly') required double employerSubscriptionWeekly,
    @JsonKey(name: 'employer_subscription_daily') required double employerSubscriptionDaily,
    @JsonKey(name: 'worker_no_show_penalty') required double workerNoShowPenalty,
    @JsonKey(name: 'employer_cancel_penalty_6h') required double employerCancelPenalty6h,
    @JsonKey(name: 'employer_cancel_penalty_3h') required double employerCancelPenalty3h,
    @JsonKey(name: 'employer_cancel_penalty_1h') required double employerCancelPenalty1h,
  }) = _PlatformConfig;

  factory PlatformConfig.fromJson(Map<String, dynamic> json) => _$PlatformConfigFromJson(json);
}

@freezed
class Dispute with _$Dispute {
  const factory Dispute({
    required String id,
    @JsonKey(name: 'gig_id') required String gigId,
    @JsonKey(name: 'worker_name') required String workerName,
    @JsonKey(name: 'business_name') required String businessName,
    @JsonKey(name: 'amount_paise') required int amountPaise,
    required String reason,
    required String status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    String? resolution,
  }) = _Dispute;

  factory Dispute.fromJson(Map<String, dynamic> json) => _$DisputeFromJson(json);
}

@freezed
class AnalyticsOverview with _$AnalyticsOverview {
  const factory AnalyticsOverview({
    @JsonKey(name: 'gigs_posted') @Default(0) int totalGigs,
    @JsonKey(name: 'total_active_workers') @Default(0) int activeWorkers,
    @JsonKey(name: 'total_verified_employers') @Default(0) int activeBusinesses,
    @JsonKey(name: 'gigs_completed') @Default(0) int completedGigs,
  }) = _AnalyticsOverview;

  factory AnalyticsOverview.fromJson(Map<String, dynamic> json) => _$AnalyticsOverviewFromJson(json);
}

@freezed
class FinancialMetrics with _$FinancialMetrics {
  const factory FinancialMetrics({
    @JsonKey(name: 'current_escrow_load_paise') @Default(0) int escrowBalancePaise,
    @JsonKey(name: 'subscription_revenue_paise') @Default(0) int subscriptionRevenuePaise,
    @JsonKey(name: 'retained_cancellation_fines_paise') @Default(0) int fineRevenuePaise,
    @JsonKey(name: 'total_worker_gmv_paise') @Default(0) int totalWorkerGmvPaise,
  }) = _FinancialMetrics;

  factory FinancialMetrics.fromJson(Map<String, dynamic> json) => _$FinancialMetricsFromJson(json);
}

@freezed
class Expenditure with _$Expenditure {
  const factory Expenditure({
    required String id,
    required String type, // RENT, SALARY, MARKETING, CLOUD, etc.
    @JsonKey(name: 'amount_paise') required int amountPaise,
    required String description,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Expenditure;

  factory Expenditure.fromJson(Map<String, dynamic> json) => _$ExpenditureFromJson(json);
}

@freezed
class PnLSummary with _$PnLSummary {
  const factory PnLSummary({
    required String month,
    @JsonKey(name: 'gross_revenue') @Default({}) Map<String, dynamic> grossRevenue,
    @JsonKey(name: 'expenditures') @Default({}) Map<String, dynamic> expenditures,
    @JsonKey(name: 'net_profit_paise') @Default(0) int netProfitPaise,
    @JsonKey(name: 'profit_margin_percentage') @Default(0.0) double profitMarginPercentage,
  }) = _PnLSummary;

  factory PnLSummary.fromJson(Map<String, dynamic> json) => _$PnLSummaryFromJson(json);
}

@freezed
class LiquidityMetrics with _$LiquidityMetrics {
  const factory LiquidityMetrics({
    @JsonKey(name: 'gig_fill_rate_percentage') required double fillRate,
    @JsonKey(name: 'worker_to_gig_ratio') required double workerRatio,
    @JsonKey(name: 'most_demanded_skill') required String topSkill,
  }) = _LiquidityMetrics;

  factory LiquidityMetrics.fromJson(Map<String, dynamic> json) => _$LiquidityMetricsFromJson(json);
}

@freezed
class PlatformHealth with _$PlatformHealth {
  const factory PlatformHealth({
    @JsonKey(name: 'no_show_rate_percentage') required double noShowRate,
    @JsonKey(name: 'emergency_trigger_rate_percentage') required double emergencyRate,
    @JsonKey(name: 'verifier_sla_breaches') required int slaBreaches,
  }) = _PlatformHealth;

  factory PlatformHealth.fromJson(Map<String, dynamic> json) => _$PlatformHealthFromJson(json);
}
