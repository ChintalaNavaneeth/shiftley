// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'employee_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EmployeeDashboardData _$EmployeeDashboardDataFromJson(
    Map<String, dynamic> json) {
  return _EmployeeDashboardData.fromJson(json);
}

/// @nodoc
mixin _$EmployeeDashboardData {
  @JsonKey(name: 'full_name')
  String get fullName => throw _privateConstructorUsedError;
  @JsonKey(name: 'overall_rating')
  double get overallRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'reliability_status')
  String get reliabilityStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'active_fine_paise')
  int get activeFinePaise => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_gigs')
  int get totalGigs => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_earned_paise')
  int get totalEarnedPaise => throw _privateConstructorUsedError;
  @JsonKey(name: 'this_month_earned_paise')
  int get thisMonthEarnedPaise => throw _privateConstructorUsedError;
  @JsonKey(name: 'no_shows')
  int get noShows => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_shift')
  Gig? get nextShift => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EmployeeDashboardDataCopyWith<EmployeeDashboardData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmployeeDashboardDataCopyWith<$Res> {
  factory $EmployeeDashboardDataCopyWith(EmployeeDashboardData value,
          $Res Function(EmployeeDashboardData) then) =
      _$EmployeeDashboardDataCopyWithImpl<$Res, EmployeeDashboardData>;
  @useResult
  $Res call(
      {@JsonKey(name: 'full_name') String fullName,
      @JsonKey(name: 'overall_rating') double overallRating,
      @JsonKey(name: 'reliability_status') String reliabilityStatus,
      @JsonKey(name: 'active_fine_paise') int activeFinePaise,
      @JsonKey(name: 'total_gigs') int totalGigs,
      @JsonKey(name: 'total_earned_paise') int totalEarnedPaise,
      @JsonKey(name: 'this_month_earned_paise') int thisMonthEarnedPaise,
      @JsonKey(name: 'no_shows') int noShows,
      @JsonKey(name: 'next_shift') Gig? nextShift});
}

/// @nodoc
class _$EmployeeDashboardDataCopyWithImpl<$Res,
        $Val extends EmployeeDashboardData>
    implements $EmployeeDashboardDataCopyWith<$Res> {
  _$EmployeeDashboardDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = null,
    Object? overallRating = null,
    Object? reliabilityStatus = null,
    Object? activeFinePaise = null,
    Object? totalGigs = null,
    Object? totalEarnedPaise = null,
    Object? thisMonthEarnedPaise = null,
    Object? noShows = null,
    Object? nextShift = freezed,
  }) {
    return _then(_value.copyWith(
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      overallRating: null == overallRating
          ? _value.overallRating
          : overallRating // ignore: cast_nullable_to_non_nullable
              as double,
      reliabilityStatus: null == reliabilityStatus
          ? _value.reliabilityStatus
          : reliabilityStatus // ignore: cast_nullable_to_non_nullable
              as String,
      activeFinePaise: null == activeFinePaise
          ? _value.activeFinePaise
          : activeFinePaise // ignore: cast_nullable_to_non_nullable
              as int,
      totalGigs: null == totalGigs
          ? _value.totalGigs
          : totalGigs // ignore: cast_nullable_to_non_nullable
              as int,
      totalEarnedPaise: null == totalEarnedPaise
          ? _value.totalEarnedPaise
          : totalEarnedPaise // ignore: cast_nullable_to_non_nullable
              as int,
      thisMonthEarnedPaise: null == thisMonthEarnedPaise
          ? _value.thisMonthEarnedPaise
          : thisMonthEarnedPaise // ignore: cast_nullable_to_non_nullable
              as int,
      noShows: null == noShows
          ? _value.noShows
          : noShows // ignore: cast_nullable_to_non_nullable
              as int,
      nextShift: freezed == nextShift
          ? _value.nextShift
          : nextShift // ignore: cast_nullable_to_non_nullable
              as Gig?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EmployeeDashboardDataImplCopyWith<$Res>
    implements $EmployeeDashboardDataCopyWith<$Res> {
  factory _$$EmployeeDashboardDataImplCopyWith(
          _$EmployeeDashboardDataImpl value,
          $Res Function(_$EmployeeDashboardDataImpl) then) =
      __$$EmployeeDashboardDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'full_name') String fullName,
      @JsonKey(name: 'overall_rating') double overallRating,
      @JsonKey(name: 'reliability_status') String reliabilityStatus,
      @JsonKey(name: 'active_fine_paise') int activeFinePaise,
      @JsonKey(name: 'total_gigs') int totalGigs,
      @JsonKey(name: 'total_earned_paise') int totalEarnedPaise,
      @JsonKey(name: 'this_month_earned_paise') int thisMonthEarnedPaise,
      @JsonKey(name: 'no_shows') int noShows,
      @JsonKey(name: 'next_shift') Gig? nextShift});
}

/// @nodoc
class __$$EmployeeDashboardDataImplCopyWithImpl<$Res>
    extends _$EmployeeDashboardDataCopyWithImpl<$Res,
        _$EmployeeDashboardDataImpl>
    implements _$$EmployeeDashboardDataImplCopyWith<$Res> {
  __$$EmployeeDashboardDataImplCopyWithImpl(_$EmployeeDashboardDataImpl _value,
      $Res Function(_$EmployeeDashboardDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = null,
    Object? overallRating = null,
    Object? reliabilityStatus = null,
    Object? activeFinePaise = null,
    Object? totalGigs = null,
    Object? totalEarnedPaise = null,
    Object? thisMonthEarnedPaise = null,
    Object? noShows = null,
    Object? nextShift = freezed,
  }) {
    return _then(_$EmployeeDashboardDataImpl(
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      overallRating: null == overallRating
          ? _value.overallRating
          : overallRating // ignore: cast_nullable_to_non_nullable
              as double,
      reliabilityStatus: null == reliabilityStatus
          ? _value.reliabilityStatus
          : reliabilityStatus // ignore: cast_nullable_to_non_nullable
              as String,
      activeFinePaise: null == activeFinePaise
          ? _value.activeFinePaise
          : activeFinePaise // ignore: cast_nullable_to_non_nullable
              as int,
      totalGigs: null == totalGigs
          ? _value.totalGigs
          : totalGigs // ignore: cast_nullable_to_non_nullable
              as int,
      totalEarnedPaise: null == totalEarnedPaise
          ? _value.totalEarnedPaise
          : totalEarnedPaise // ignore: cast_nullable_to_non_nullable
              as int,
      thisMonthEarnedPaise: null == thisMonthEarnedPaise
          ? _value.thisMonthEarnedPaise
          : thisMonthEarnedPaise // ignore: cast_nullable_to_non_nullable
              as int,
      noShows: null == noShows
          ? _value.noShows
          : noShows // ignore: cast_nullable_to_non_nullable
              as int,
      nextShift: freezed == nextShift
          ? _value.nextShift
          : nextShift // ignore: cast_nullable_to_non_nullable
              as Gig?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EmployeeDashboardDataImpl implements _EmployeeDashboardData {
  const _$EmployeeDashboardDataImpl(
      {@JsonKey(name: 'full_name') required this.fullName,
      @JsonKey(name: 'overall_rating') required this.overallRating,
      @JsonKey(name: 'reliability_status') required this.reliabilityStatus,
      @JsonKey(name: 'active_fine_paise') required this.activeFinePaise,
      @JsonKey(name: 'total_gigs') required this.totalGigs,
      @JsonKey(name: 'total_earned_paise') required this.totalEarnedPaise,
      @JsonKey(name: 'this_month_earned_paise')
      required this.thisMonthEarnedPaise,
      @JsonKey(name: 'no_shows') required this.noShows,
      @JsonKey(name: 'next_shift') this.nextShift});

  factory _$EmployeeDashboardDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmployeeDashboardDataImplFromJson(json);

  @override
  @JsonKey(name: 'full_name')
  final String fullName;
  @override
  @JsonKey(name: 'overall_rating')
  final double overallRating;
  @override
  @JsonKey(name: 'reliability_status')
  final String reliabilityStatus;
  @override
  @JsonKey(name: 'active_fine_paise')
  final int activeFinePaise;
  @override
  @JsonKey(name: 'total_gigs')
  final int totalGigs;
  @override
  @JsonKey(name: 'total_earned_paise')
  final int totalEarnedPaise;
  @override
  @JsonKey(name: 'this_month_earned_paise')
  final int thisMonthEarnedPaise;
  @override
  @JsonKey(name: 'no_shows')
  final int noShows;
  @override
  @JsonKey(name: 'next_shift')
  final Gig? nextShift;

  @override
  String toString() {
    return 'EmployeeDashboardData(fullName: $fullName, overallRating: $overallRating, reliabilityStatus: $reliabilityStatus, activeFinePaise: $activeFinePaise, totalGigs: $totalGigs, totalEarnedPaise: $totalEarnedPaise, thisMonthEarnedPaise: $thisMonthEarnedPaise, noShows: $noShows, nextShift: $nextShift)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmployeeDashboardDataImpl &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.overallRating, overallRating) ||
                other.overallRating == overallRating) &&
            (identical(other.reliabilityStatus, reliabilityStatus) ||
                other.reliabilityStatus == reliabilityStatus) &&
            (identical(other.activeFinePaise, activeFinePaise) ||
                other.activeFinePaise == activeFinePaise) &&
            (identical(other.totalGigs, totalGigs) ||
                other.totalGigs == totalGigs) &&
            (identical(other.totalEarnedPaise, totalEarnedPaise) ||
                other.totalEarnedPaise == totalEarnedPaise) &&
            (identical(other.thisMonthEarnedPaise, thisMonthEarnedPaise) ||
                other.thisMonthEarnedPaise == thisMonthEarnedPaise) &&
            (identical(other.noShows, noShows) || other.noShows == noShows) &&
            (identical(other.nextShift, nextShift) ||
                other.nextShift == nextShift));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      fullName,
      overallRating,
      reliabilityStatus,
      activeFinePaise,
      totalGigs,
      totalEarnedPaise,
      thisMonthEarnedPaise,
      noShows,
      nextShift);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EmployeeDashboardDataImplCopyWith<_$EmployeeDashboardDataImpl>
      get copyWith => __$$EmployeeDashboardDataImplCopyWithImpl<
          _$EmployeeDashboardDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EmployeeDashboardDataImplToJson(
      this,
    );
  }
}

abstract class _EmployeeDashboardData implements EmployeeDashboardData {
  const factory _EmployeeDashboardData(
      {@JsonKey(name: 'full_name') required final String fullName,
      @JsonKey(name: 'overall_rating') required final double overallRating,
      @JsonKey(name: 'reliability_status')
      required final String reliabilityStatus,
      @JsonKey(name: 'active_fine_paise') required final int activeFinePaise,
      @JsonKey(name: 'total_gigs') required final int totalGigs,
      @JsonKey(name: 'total_earned_paise') required final int totalEarnedPaise,
      @JsonKey(name: 'this_month_earned_paise')
      required final int thisMonthEarnedPaise,
      @JsonKey(name: 'no_shows') required final int noShows,
      @JsonKey(name: 'next_shift')
      final Gig? nextShift}) = _$EmployeeDashboardDataImpl;

  factory _EmployeeDashboardData.fromJson(Map<String, dynamic> json) =
      _$EmployeeDashboardDataImpl.fromJson;

  @override
  @JsonKey(name: 'full_name')
  String get fullName;
  @override
  @JsonKey(name: 'overall_rating')
  double get overallRating;
  @override
  @JsonKey(name: 'reliability_status')
  String get reliabilityStatus;
  @override
  @JsonKey(name: 'active_fine_paise')
  int get activeFinePaise;
  @override
  @JsonKey(name: 'total_gigs')
  int get totalGigs;
  @override
  @JsonKey(name: 'total_earned_paise')
  int get totalEarnedPaise;
  @override
  @JsonKey(name: 'this_month_earned_paise')
  int get thisMonthEarnedPaise;
  @override
  @JsonKey(name: 'no_shows')
  int get noShows;
  @override
  @JsonKey(name: 'next_shift')
  Gig? get nextShift;
  @override
  @JsonKey(ignore: true)
  _$$EmployeeDashboardDataImplCopyWith<_$EmployeeDashboardDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}
