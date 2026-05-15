// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EmployeeDashboardDataImpl _$$EmployeeDashboardDataImplFromJson(
        Map<String, dynamic> json) =>
    _$EmployeeDashboardDataImpl(
      fullName: json['full_name'] as String,
      overallRating: (json['overall_rating'] as num).toDouble(),
      reliabilityStatus: json['reliability_status'] as String,
      activeFinePaise: (json['active_fine_paise'] as num).toInt(),
      totalGigs: (json['total_gigs'] as num).toInt(),
      totalEarnedPaise: (json['total_earned_paise'] as num).toInt(),
      thisMonthEarnedPaise: (json['this_month_earned_paise'] as num).toInt(),
      noShows: (json['no_shows'] as num).toInt(),
      nextShift: json['next_shift'] == null
          ? null
          : Gig.fromJson(json['next_shift'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$EmployeeDashboardDataImplToJson(
        _$EmployeeDashboardDataImpl instance) =>
    <String, dynamic>{
      'full_name': instance.fullName,
      'overall_rating': instance.overallRating,
      'reliability_status': instance.reliabilityStatus,
      'active_fine_paise': instance.activeFinePaise,
      'total_gigs': instance.totalGigs,
      'total_earned_paise': instance.totalEarnedPaise,
      'this_month_earned_paise': instance.thisMonthEarnedPaise,
      'no_shows': instance.noShows,
      'next_shift': instance.nextShift,
    };
