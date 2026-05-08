import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_models.freezed.dart';
part 'admin_models.g.dart';

@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    @JsonKey(name: 'is_active') required bool isActive,
    @Default([]) List<Skill> skills,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
}

@freezed
class Skill with _$Skill {
  const factory Skill({
    required String id,
    @JsonKey(name: 'category_id') required String categoryId,
    required String name,
    @JsonKey(name: 'is_active') required bool isActive,
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
    @JsonKey(name: 'fee_percentage') required double feePercentage,
    @JsonKey(name: 'min_wage_paise') required int minWagePaise,
    @JsonKey(name: 'max_workers_per_gig') required int maxWorkersPerGig,
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
    @JsonKey(name: 'total_gigs') required int totalGigs,
    @JsonKey(name: 'active_workers') required int activeWorkers,
    @JsonKey(name: 'active_businesses') required int activeBusinesses,
    @JsonKey(name: 'total_revenue_paise') required int totalRevenuePaise,
  }) = _AnalyticsOverview;

  factory AnalyticsOverview.fromJson(Map<String, dynamic> json) => _$AnalyticsOverviewFromJson(json);
}

@freezed
class FinancialMetrics with _$FinancialMetrics {
  const factory FinancialMetrics({
    @JsonKey(name: 'escrow_balance_paise') required int escrowBalancePaise,
    @JsonKey(name: 'total_payouts_paise') required int totalPayoutsPaise,
    @JsonKey(name: 'commission_earned_paise') required int commissionEarnedPaise,
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
