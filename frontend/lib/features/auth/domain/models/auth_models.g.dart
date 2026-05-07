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
    );

Map<String, dynamic> _$SendOtpRequestToJson(SendOtpRequest instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'type': instance.type,
      'role': instance.role,
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
      status: json['status'] as bool,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : AuthData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
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
