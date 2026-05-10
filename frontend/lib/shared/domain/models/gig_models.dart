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
    required this.createdAt,
  });

  factory Gig.fromJson(Map<String, dynamic> json) => _$GigFromJson(json);
  Map<String, dynamic> toJson() => _$GigToJson(this);
}
