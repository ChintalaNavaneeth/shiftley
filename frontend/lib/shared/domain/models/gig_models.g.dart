// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gig_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Gig _$GigFromJson(Map<String, dynamic> json) => Gig(
      id: json['id'] as String,
      employerId: json['employer_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      categoryId: json['category_id'] as String,
      skillId: json['skill_id'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      address: json['address'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      payType: json['pay_type'] as String,
      wagePerWorker: (json['wage_per_worker'] as num).toInt(),
      workersNeeded: (json['workers_needed'] as num).toInt(),
      status: json['status'] as String,
      cancelReason: json['cancel_reason'] as String?,
      isEscrowFunded: json['is_escrow_funded'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      businessName: json['business_name'] as String?,
      businessType: json['business_type'] as String?,
      photoUrls: (json['photo_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      distanceMeters: (json['distance_meters'] as num?)?.toDouble(),
      myApplicationStatus: json['my_application_status'] as String?,
    );

Map<String, dynamic> _$GigToJson(Gig instance) => <String, dynamic>{
      'id': instance.id,
      'employer_id': instance.employerId,
      'title': instance.title,
      'description': instance.description,
      'category_id': instance.categoryId,
      'skill_id': instance.skillId,
      'lat': instance.lat,
      'lng': instance.lng,
      'address': instance.address,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'pay_type': instance.payType,
      'wage_per_worker': instance.wagePerWorker,
      'workers_needed': instance.workersNeeded,
      'status': instance.status,
      'cancel_reason': instance.cancelReason,
      'is_escrow_funded': instance.isEscrowFunded,
      'created_at': instance.createdAt.toIso8601String(),
      'business_name': instance.businessName,
      'business_type': instance.businessType,
      'photo_urls': instance.photoUrls,
      'distance_meters': instance.distanceMeters,
      'my_application_status': instance.myApplicationStatus,
    };

GigApplication _$GigApplicationFromJson(Map<String, dynamic> json) =>
    GigApplication(
      id: json['id'] as String,
      gigId: json['gig_id'] as String,
      employeeId: json['employee_id'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      employeeName: json['employee_name'] as String?,
      employeeRating: (json['employee_rating'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$GigApplicationToJson(GigApplication instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gig_id': instance.gigId,
      'employee_id': instance.employeeId,
      'status': instance.status,
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'employee_name': instance.employeeName,
      'employee_rating': instance.employeeRating,
    };

GigAttendance _$GigAttendanceFromJson(Map<String, dynamic> json) =>
    GigAttendance(
      id: json['id'] as String,
      gigId: json['gig_id'] as String,
      employeeId: json['employee_id'] as String,
      clockIn: json['clock_in'] == null
          ? null
          : DateTime.parse(json['clock_in'] as String),
      clockOut: json['clock_out'] == null
          ? null
          : DateTime.parse(json['clock_out'] as String),
      status: json['status'] as String,
    );

Map<String, dynamic> _$GigAttendanceToJson(GigAttendance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gig_id': instance.gigId,
      'employee_id': instance.employeeId,
      'clock_in': instance.clockIn?.toIso8601String(),
      'clock_out': instance.clockOut?.toIso8601String(),
      'status': instance.status,
    };
