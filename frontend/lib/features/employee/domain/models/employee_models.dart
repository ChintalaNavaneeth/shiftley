import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiftley_frontend/shared/domain/models/gig_models.dart';

part 'employee_models.freezed.dart';
part 'employee_models.g.dart';

@freezed
class EmployeeDashboardData with _$EmployeeDashboardData {
  const factory EmployeeDashboardData({
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'overall_rating') required double overallRating,
    @JsonKey(name: 'reliability_status') required String reliabilityStatus,
    @JsonKey(name: 'active_fine_paise') required int activeFinePaise,
    @JsonKey(name: 'total_gigs') required int totalGigs,
    @JsonKey(name: 'total_earned_paise') required int totalEarnedPaise,
    @JsonKey(name: 'this_month_earned_paise') required int thisMonthEarnedPaise,
    @JsonKey(name: 'no_shows') required int noShows,
    @JsonKey(name: 'next_shift') Gig? nextShift,
  }) = _EmployeeDashboardData;

  factory EmployeeDashboardData.fromJson(Map<String, dynamic> json) => _$EmployeeDashboardDataFromJson(json);
}
