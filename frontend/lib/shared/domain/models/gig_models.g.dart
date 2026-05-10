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
      createdAt: DateTime.parse(json['created_at'] as String),
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
      'created_at': instance.createdAt.toIso8601String(),
    };
