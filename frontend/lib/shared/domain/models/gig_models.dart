import 'package:json_annotation/json_annotation.dart';

part 'gig_models.g.dart';

@JsonSerializable()
class Gig {
  final String id;
  @JsonKey(name: 'employer_id')
  final String employerId;
  final String title;
  final String description;
  @JsonKey(name: 'category_id')
  final String categoryId;
  @JsonKey(name: 'skill_id')
  final String skillId;
  final double lat;
  final double lng;
  final String address;
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @JsonKey(name: 'end_time')
  final DateTime endTime;
  @JsonKey(name: 'pay_type')
  final String payType;
  @JsonKey(name: 'wage_per_worker')
  final int wagePerWorker;
  @JsonKey(name: 'workers_needed')
  final int workersNeeded;
  final String status;
  @JsonKey(name: 'cancel_reason')
  final String? cancelReason;
  @JsonKey(name: 'is_escrow_funded', defaultValue: false)
  final bool isEscrowFunded;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Gig({
    required this.id,
    required this.employerId,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.skillId,
    required this.lat,
    required this.lng,
    required this.address,
    required this.startTime,
    required this.endTime,
    required this.payType,
    required this.wagePerWorker,
    required this.workersNeeded,
    required this.status,
    this.cancelReason,
    this.isEscrowFunded = false,
    required this.createdAt,
  });

  factory Gig.fromJson(Map<String, dynamic> json) => _$GigFromJson(json);
  Map<String, dynamic> toJson() => _$GigToJson(this);
}

@JsonSerializable()
class GigApplication {
  final String id;
  @JsonKey(name: 'gig_id')
  final String gigId;
  @JsonKey(name: 'employee_id')
  final String employeeId;
  final String status;
  final String? notes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'employee_name') // Calculated or joined in some responses
  final String? employeeName;
  @JsonKey(name: 'employee_rating')
  final double? employeeRating;

  GigApplication({
    required this.id,
    required this.gigId,
    required this.employeeId,
    required this.status,
    this.notes,
    required this.createdAt,
    this.employeeName,
    this.employeeRating,
  });

  factory GigApplication.fromJson(Map<String, dynamic> json) => _$GigApplicationFromJson(json);
  Map<String, dynamic> toJson() => _$GigApplicationToJson(this);
}

@JsonSerializable()
class GigAttendance {
  final String id;
  @JsonKey(name: 'gig_id')
  final String gigId;
  @JsonKey(name: 'employee_id')
  final String employeeId;
  @JsonKey(name: 'clock_in')
  final DateTime? clockIn;
  @JsonKey(name: 'clock_out')
  final DateTime? clockOut;
  final String status;

  GigAttendance({
    required this.id,
    required this.gigId,
    required this.employeeId,
    this.clockIn,
    this.clockOut,
    required this.status,
  });

  factory GigAttendance.fromJson(Map<String, dynamic> json) => _$GigAttendanceFromJson(json);
  Map<String, dynamic> toJson() => _$GigAttendanceToJson(this);
}
