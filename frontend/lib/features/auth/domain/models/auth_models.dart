import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class SendOtpRequest {
  final String identifier;
  final String type;
  final String role;
  final String? intent;

  SendOtpRequest({
    required this.identifier,
    required this.type,
    required this.role,
    this.intent,
  });

  factory SendOtpRequest.fromJson(Map<String, dynamic> json) => _$SendOtpRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SendOtpRequestToJson(this);
}

@JsonSerializable()
class VerifyOtpRequest {
  final String identifier;
  final String type;
  final String code;
  final String? role;

  VerifyOtpRequest({
    required this.identifier,
    required this.type,
    required this.code,
    this.role,
  });

  factory VerifyOtpRequest.fromJson(Map<String, dynamic> json) => _$VerifyOtpRequestFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyOtpRequestToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final bool success;
  final String? message;
  final dynamic data;

  AuthResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class AuthData {
  @JsonKey(name: 'is_new_user')
  final bool isNewUser;
  
  @JsonKey(name: 'access_token')
  final String? accessToken;
  
  @JsonKey(name: 'registration_token')
  final String? registrationToken;
  
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;

  @JsonKey(name: 'is_initial_setup_complete')
  final bool? isInitialSetupComplete;

  final UserData? user;

  AuthData({
    required this.isNewUser,
    this.accessToken,
    this.registrationToken,
    this.refreshToken,
    this.isInitialSetupComplete,
    this.user,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) => _$AuthDataFromJson(json);
  Map<String, dynamic> toJson() => _$AuthDataToJson(this);
}

@JsonSerializable()
class UserData {
  final String id;
  final String role;
  @JsonKey(name: 'is_verified')
  final bool isVerified;

  UserData({
    required this.id,
    required this.role,
    required this.isVerified,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => _$UserDataFromJson(json);
  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}

@JsonSerializable()
class Category {
  final String id;
  final String name;
  final List<Skill> skills;

  Category({required this.id, required this.name, required this.skills});

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class Skill {
  final String id;
  final String name;

  Skill({required this.id, required this.name});

  factory Skill.fromJson(Map<String, dynamic> json) => _$SkillFromJson(json);
  Map<String, dynamic> toJson() => _$SkillToJson(this);
}
