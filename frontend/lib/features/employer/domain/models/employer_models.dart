import 'package:json_annotation/json_annotation.dart';

part 'employer_models.g.dart';

@JsonSerializable()
class EmployerProfile {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'business_name')
  final String businessName;
  @JsonKey(name: 'business_type')
  final String businessType;
  @JsonKey(name: 'gst_number')
  final String? gstNumber;
  @JsonKey(name: 'business_address')
  final String businessAddress;
  @JsonKey(defaultValue: '')
  final String email;
  @JsonKey(name: 'phone_number', defaultValue: '')
  final String phoneNumber;
  @JsonKey(name: 'full_name', defaultValue: 'Employer')
  final String fullName;
  final double lat;
  final double lng;
  @JsonKey(name: 'verification_status')
  final String verificationStatus;
  @JsonKey(name: 'aadhaar_last_4')
  final String? aadhaarLast4;
  @JsonKey(name: 'aadhaar_url')
  final String? aadhaarUrl;
  @JsonKey(name: 'photo_urls')
  final List<String> photoUrls;

  EmployerProfile({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.businessType,
    this.gstNumber,
    required this.businessAddress,
    required this.email,
    required this.phoneNumber,
    required this.fullName,
    required this.lat,
    required this.lng,
    required this.verificationStatus,
    this.aadhaarLast4,
    this.aadhaarUrl,
    required this.photoUrls,
  });

  factory EmployerProfile.fromJson(Map<String, dynamic> json) => _$EmployerProfileFromJson(json);
  Map<String, dynamic> toJson() => _$EmployerProfileToJson(this);
}

@JsonSerializable()
class EmployerStats {
  @JsonKey(name: 'total_gigs_posted')
  final int totalGigsPosted;
  @JsonKey(name: 'active_plan')
  final String activePlan;
  @JsonKey(name: 'plan_expires_at')
  final DateTime? planExpiresAt;
  @JsonKey(name: 'free_gigs_remaining')
  final int freeGigsRemaining;

  EmployerStats({
    required this.totalGigsPosted,
    required this.activePlan,
    this.planExpiresAt,
    required this.freeGigsRemaining,
  });

  factory EmployerStats.fromJson(Map<String, dynamic> json) => _$EmployerStatsFromJson(json);
  Map<String, dynamic> toJson() => _$EmployerStatsToJson(this);
}

@JsonSerializable()
class SubscriptionPlanMeta {
  final String id;
  final String name;
  @JsonKey(name: 'price_paise')
  final int pricePaise;
  @JsonKey(name: 'duration_days')
  final int durationDays;
  @JsonKey(name: 'max_gigs')
  final int maxGigs;
  @JsonKey(name: 'max_employees_per_gig')
  final int maxEmployeesPerGig;

  SubscriptionPlanMeta({
    required this.id,
    required this.name,
    required this.pricePaise,
    required this.durationDays,
    required this.maxGigs,
    required this.maxEmployeesPerGig,
  });

  factory SubscriptionPlanMeta.fromJson(Map<String, dynamic> json) => _$SubscriptionPlanMetaFromJson(json);
  Map<String, dynamic> toJson() => _$SubscriptionPlanMetaToJson(this);
}

@JsonSerializable()
class EmployerDashboardData {
  final EmployerProfile profile;
  final EmployerStats stats;
  @JsonKey(name: 'available_plans', defaultValue: [])
  final List<SubscriptionPlanMeta> availablePlans;

  EmployerDashboardData({
    required this.profile,
    required this.stats,
    required this.availablePlans,
  });

  factory EmployerDashboardData.fromJson(Map<String, dynamic> json) => _$EmployerDashboardDataFromJson(json);
  Map<String, dynamic> toJson() => _$EmployerDashboardDataToJson(this);
}
