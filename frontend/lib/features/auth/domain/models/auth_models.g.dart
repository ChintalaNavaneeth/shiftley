// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendOtpRequest _$SendOtpRequestFromJson(Map<String, dynamic> json) =>
    SendOtpRequest(
      identifier: json['identifier'] as String,
      type: json['type'] as String,
      role: json['role'] as String,
      intent: json['intent'] as String?,
    );

Map<String, dynamic> _$SendOtpRequestToJson(SendOtpRequest instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'type': instance.type,
      'role': instance.role,
      'intent': instance.intent,
    };

VerifyOtpRequest _$VerifyOtpRequestFromJson(Map<String, dynamic> json) =>
    VerifyOtpRequest(
      identifier: json['identifier'] as String,
      type: json['type'] as String,
      code: json['code'] as String,
    );

Map<String, dynamic> _$VerifyOtpRequestToJson(VerifyOtpRequest instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'type': instance.type,
      'code': instance.code,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'],
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

AuthData _$AuthDataFromJson(Map<String, dynamic> json) => AuthData(
      isNewUser: json['is_new_user'] as bool,
      accessToken: json['access_token'] as String?,
      registrationToken: json['registration_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      isInitialSetupComplete: json['is_initial_setup_complete'] as bool?,
      user: json['user'] == null
          ? null
          : UserData.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthDataToJson(AuthData instance) => <String, dynamic>{
      'is_new_user': instance.isNewUser,
      'access_token': instance.accessToken,
      'registration_token': instance.registrationToken,
      'refresh_token': instance.refreshToken,
      'is_initial_setup_complete': instance.isInitialSetupComplete,
      'user': instance.user,
    };

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
      id: json['id'] as String,
      role: json['role'] as String,
      isVerified: json['is_verified'] as bool,
    );

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'id': instance.id,
      'role': instance.role,
      'is_verified': instance.isVerified,
    };

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: json['id'] as String,
      name: json['name'] as String,
      skills: (json['skills'] as List<dynamic>)
          .map((e) => Skill.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'skills': instance.skills,
    };

Skill _$SkillFromJson(Map<String, dynamic> json) => Skill(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$SkillToJson(Skill instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
