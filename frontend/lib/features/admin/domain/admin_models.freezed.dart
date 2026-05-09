// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Category _$CategoryFromJson(Map<String, dynamic> json) {
  return _Category.fromJson(json);
}

/// @nodoc
mixin _$Category {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  List<Skill> get skills => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CategoryCopyWith<Category> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryCopyWith<$Res> {
  factory $CategoryCopyWith(Category value, $Res Function(Category) then) =
      _$CategoryCopyWithImpl<$Res, Category>;
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(name: 'is_active') bool isActive,
      List<Skill> skills});
}

/// @nodoc
class _$CategoryCopyWithImpl<$Res, $Val extends Category>
    implements $CategoryCopyWith<$Res> {
  _$CategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? isActive = null,
    Object? skills = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      skills: null == skills
          ? _value.skills
          : skills // ignore: cast_nullable_to_non_nullable
              as List<Skill>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CategoryImplCopyWith<$Res>
    implements $CategoryCopyWith<$Res> {
  factory _$$CategoryImplCopyWith(
          _$CategoryImpl value, $Res Function(_$CategoryImpl) then) =
      __$$CategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(name: 'is_active') bool isActive,
      List<Skill> skills});
}

/// @nodoc
class __$$CategoryImplCopyWithImpl<$Res>
    extends _$CategoryCopyWithImpl<$Res, _$CategoryImpl>
    implements _$$CategoryImplCopyWith<$Res> {
  __$$CategoryImplCopyWithImpl(
      _$CategoryImpl _value, $Res Function(_$CategoryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? isActive = null,
    Object? skills = null,
  }) {
    return _then(_$CategoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      skills: null == skills
          ? _value._skills
          : skills // ignore: cast_nullable_to_non_nullable
              as List<Skill>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CategoryImpl implements _Category {
  const _$CategoryImpl(
      {required this.id,
      required this.name,
      @JsonKey(name: 'is_active') required this.isActive,
      final List<Skill> skills = const []})
      : _skills = skills;

  factory _$CategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategoryImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  final List<Skill> _skills;
  @override
  @JsonKey()
  List<Skill> get skills {
    if (_skills is EqualUnmodifiableListView) return _skills;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_skills);
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, isActive: $isActive, skills: $skills)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality().equals(other._skills, _skills));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, isActive,
      const DeepCollectionEquality().hash(_skills));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryImplCopyWith<_$CategoryImpl> get copyWith =>
      __$$CategoryImplCopyWithImpl<_$CategoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategoryImplToJson(
      this,
    );
  }
}

abstract class _Category implements Category {
  const factory _Category(
      {required final String id,
      required final String name,
      @JsonKey(name: 'is_active') required final bool isActive,
      final List<Skill> skills}) = _$CategoryImpl;

  factory _Category.fromJson(Map<String, dynamic> json) =
      _$CategoryImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  List<Skill> get skills;
  @override
  @JsonKey(ignore: true)
  _$$CategoryImplCopyWith<_$CategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Skill _$SkillFromJson(Map<String, dynamic> json) {
  return _Skill.fromJson(json);
}

/// @nodoc
mixin _$Skill {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_id')
  String get categoryId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SkillCopyWith<Skill> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SkillCopyWith<$Res> {
  factory $SkillCopyWith(Skill value, $Res Function(Skill) then) =
      _$SkillCopyWithImpl<$Res, Skill>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'category_id') String categoryId,
      String name,
      @JsonKey(name: 'is_active') bool isActive});
}

/// @nodoc
class _$SkillCopyWithImpl<$Res, $Val extends Skill>
    implements $SkillCopyWith<$Res> {
  _$SkillCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? categoryId = null,
    Object? name = null,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SkillImplCopyWith<$Res> implements $SkillCopyWith<$Res> {
  factory _$$SkillImplCopyWith(
          _$SkillImpl value, $Res Function(_$SkillImpl) then) =
      __$$SkillImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'category_id') String categoryId,
      String name,
      @JsonKey(name: 'is_active') bool isActive});
}

/// @nodoc
class __$$SkillImplCopyWithImpl<$Res>
    extends _$SkillCopyWithImpl<$Res, _$SkillImpl>
    implements _$$SkillImplCopyWith<$Res> {
  __$$SkillImplCopyWithImpl(
      _$SkillImpl _value, $Res Function(_$SkillImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? categoryId = null,
    Object? name = null,
    Object? isActive = null,
  }) {
    return _then(_$SkillImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SkillImpl implements _Skill {
  const _$SkillImpl(
      {required this.id,
      @JsonKey(name: 'category_id') required this.categoryId,
      required this.name,
      @JsonKey(name: 'is_active') required this.isActive});

  factory _$SkillImpl.fromJson(Map<String, dynamic> json) =>
      _$$SkillImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'category_id')
  final String categoryId;
  @override
  final String name;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;

  @override
  String toString() {
    return 'Skill(id: $id, categoryId: $categoryId, name: $name, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SkillImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, categoryId, name, isActive);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SkillImplCopyWith<_$SkillImpl> get copyWith =>
      __$$SkillImplCopyWithImpl<_$SkillImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SkillImplToJson(
      this,
    );
  }
}

abstract class _Skill implements Skill {
  const factory _Skill(
      {required final String id,
      @JsonKey(name: 'category_id') required final String categoryId,
      required final String name,
      @JsonKey(name: 'is_active') required final bool isActive}) = _$SkillImpl;

  factory _Skill.fromJson(Map<String, dynamic> json) = _$SkillImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'category_id')
  String get categoryId;
  @override
  String get name;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(ignore: true)
  _$$SkillImplCopyWith<_$SkillImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ManagementUser _$ManagementUserFromJson(Map<String, dynamic> json) {
  return _ManagementUser.fromJson(json);
}

/// @nodoc
mixin _$ManagementUser {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String get fullName => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'phone_number')
  String get phoneNumber => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ManagementUserCopyWith<ManagementUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ManagementUserCopyWith<$Res> {
  factory $ManagementUserCopyWith(
          ManagementUser value, $Res Function(ManagementUser) then) =
      _$ManagementUserCopyWithImpl<$Res, ManagementUser>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'full_name') String fullName,
      String email,
      @JsonKey(name: 'phone_number') String phoneNumber,
      String role,
      String status,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$ManagementUserCopyWithImpl<$Res, $Val extends ManagementUser>
    implements $ManagementUserCopyWith<$Res> {
  _$ManagementUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? email = null,
    Object? phoneNumber = null,
    Object? role = null,
    Object? status = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ManagementUserImplCopyWith<$Res>
    implements $ManagementUserCopyWith<$Res> {
  factory _$$ManagementUserImplCopyWith(_$ManagementUserImpl value,
          $Res Function(_$ManagementUserImpl) then) =
      __$$ManagementUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'full_name') String fullName,
      String email,
      @JsonKey(name: 'phone_number') String phoneNumber,
      String role,
      String status,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$ManagementUserImplCopyWithImpl<$Res>
    extends _$ManagementUserCopyWithImpl<$Res, _$ManagementUserImpl>
    implements _$$ManagementUserImplCopyWith<$Res> {
  __$$ManagementUserImplCopyWithImpl(
      _$ManagementUserImpl _value, $Res Function(_$ManagementUserImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? email = null,
    Object? phoneNumber = null,
    Object? role = null,
    Object? status = null,
    Object? createdAt = null,
  }) {
    return _then(_$ManagementUserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ManagementUserImpl implements _ManagementUser {
  const _$ManagementUserImpl(
      {required this.id,
      @JsonKey(name: 'full_name') required this.fullName,
      required this.email,
      @JsonKey(name: 'phone_number') required this.phoneNumber,
      required this.role,
      required this.status,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$ManagementUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$ManagementUserImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'full_name')
  final String fullName;
  @override
  final String email;
  @override
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  @override
  final String role;
  @override
  final String status;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'ManagementUser(id: $id, fullName: $fullName, email: $email, phoneNumber: $phoneNumber, role: $role, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ManagementUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, fullName, email, phoneNumber, role, status, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ManagementUserImplCopyWith<_$ManagementUserImpl> get copyWith =>
      __$$ManagementUserImplCopyWithImpl<_$ManagementUserImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ManagementUserImplToJson(
      this,
    );
  }
}

abstract class _ManagementUser implements ManagementUser {
  const factory _ManagementUser(
          {required final String id,
          @JsonKey(name: 'full_name') required final String fullName,
          required final String email,
          @JsonKey(name: 'phone_number') required final String phoneNumber,
          required final String role,
          required final String status,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$ManagementUserImpl;

  factory _ManagementUser.fromJson(Map<String, dynamic> json) =
      _$ManagementUserImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'full_name')
  String get fullName;
  @override
  String get email;
  @override
  @JsonKey(name: 'phone_number')
  String get phoneNumber;
  @override
  String get role;
  @override
  String get status;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$ManagementUserImplCopyWith<_$ManagementUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlatformConfig _$PlatformConfigFromJson(Map<String, dynamic> json) {
  return _PlatformConfig.fromJson(json);
}

/// @nodoc
mixin _$PlatformConfig {
  @JsonKey(name: 'employer_subscription_monthly')
  double get employerSubscriptionMonthly => throw _privateConstructorUsedError;
  @JsonKey(name: 'employer_subscription_weekly')
  double get employerSubscriptionWeekly => throw _privateConstructorUsedError;
  @JsonKey(name: 'employer_subscription_daily')
  double get employerSubscriptionDaily => throw _privateConstructorUsedError;
  @JsonKey(name: 'worker_no_show_penalty')
  double get workerNoShowPenalty => throw _privateConstructorUsedError;
  @JsonKey(name: 'employer_cancel_penalty_6h')
  double get employerCancelPenalty6h => throw _privateConstructorUsedError;
  @JsonKey(name: 'employer_cancel_penalty_3h')
  double get employerCancelPenalty3h => throw _privateConstructorUsedError;
  @JsonKey(name: 'employer_cancel_penalty_1h')
  double get employerCancelPenalty1h => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlatformConfigCopyWith<PlatformConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlatformConfigCopyWith<$Res> {
  factory $PlatformConfigCopyWith(
          PlatformConfig value, $Res Function(PlatformConfig) then) =
      _$PlatformConfigCopyWithImpl<$Res, PlatformConfig>;
  @useResult
  $Res call(
      {@JsonKey(name: 'employer_subscription_monthly')
      double employerSubscriptionMonthly,
      @JsonKey(name: 'employer_subscription_weekly')
      double employerSubscriptionWeekly,
      @JsonKey(name: 'employer_subscription_daily')
      double employerSubscriptionDaily,
      @JsonKey(name: 'worker_no_show_penalty') double workerNoShowPenalty,
      @JsonKey(name: 'employer_cancel_penalty_6h')
      double employerCancelPenalty6h,
      @JsonKey(name: 'employer_cancel_penalty_3h')
      double employerCancelPenalty3h,
      @JsonKey(name: 'employer_cancel_penalty_1h')
      double employerCancelPenalty1h});
}

/// @nodoc
class _$PlatformConfigCopyWithImpl<$Res, $Val extends PlatformConfig>
    implements $PlatformConfigCopyWith<$Res> {
  _$PlatformConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? employerSubscriptionMonthly = null,
    Object? employerSubscriptionWeekly = null,
    Object? employerSubscriptionDaily = null,
    Object? workerNoShowPenalty = null,
    Object? employerCancelPenalty6h = null,
    Object? employerCancelPenalty3h = null,
    Object? employerCancelPenalty1h = null,
  }) {
    return _then(_value.copyWith(
      employerSubscriptionMonthly: null == employerSubscriptionMonthly
          ? _value.employerSubscriptionMonthly
          : employerSubscriptionMonthly // ignore: cast_nullable_to_non_nullable
              as double,
      employerSubscriptionWeekly: null == employerSubscriptionWeekly
          ? _value.employerSubscriptionWeekly
          : employerSubscriptionWeekly // ignore: cast_nullable_to_non_nullable
              as double,
      employerSubscriptionDaily: null == employerSubscriptionDaily
          ? _value.employerSubscriptionDaily
          : employerSubscriptionDaily // ignore: cast_nullable_to_non_nullable
              as double,
      workerNoShowPenalty: null == workerNoShowPenalty
          ? _value.workerNoShowPenalty
          : workerNoShowPenalty // ignore: cast_nullable_to_non_nullable
              as double,
      employerCancelPenalty6h: null == employerCancelPenalty6h
          ? _value.employerCancelPenalty6h
          : employerCancelPenalty6h // ignore: cast_nullable_to_non_nullable
              as double,
      employerCancelPenalty3h: null == employerCancelPenalty3h
          ? _value.employerCancelPenalty3h
          : employerCancelPenalty3h // ignore: cast_nullable_to_non_nullable
              as double,
      employerCancelPenalty1h: null == employerCancelPenalty1h
          ? _value.employerCancelPenalty1h
          : employerCancelPenalty1h // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlatformConfigImplCopyWith<$Res>
    implements $PlatformConfigCopyWith<$Res> {
  factory _$$PlatformConfigImplCopyWith(_$PlatformConfigImpl value,
          $Res Function(_$PlatformConfigImpl) then) =
      __$$PlatformConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'employer_subscription_monthly')
      double employerSubscriptionMonthly,
      @JsonKey(name: 'employer_subscription_weekly')
      double employerSubscriptionWeekly,
      @JsonKey(name: 'employer_subscription_daily')
      double employerSubscriptionDaily,
      @JsonKey(name: 'worker_no_show_penalty') double workerNoShowPenalty,
      @JsonKey(name: 'employer_cancel_penalty_6h')
      double employerCancelPenalty6h,
      @JsonKey(name: 'employer_cancel_penalty_3h')
      double employerCancelPenalty3h,
      @JsonKey(name: 'employer_cancel_penalty_1h')
      double employerCancelPenalty1h});
}

/// @nodoc
class __$$PlatformConfigImplCopyWithImpl<$Res>
    extends _$PlatformConfigCopyWithImpl<$Res, _$PlatformConfigImpl>
    implements _$$PlatformConfigImplCopyWith<$Res> {
  __$$PlatformConfigImplCopyWithImpl(
      _$PlatformConfigImpl _value, $Res Function(_$PlatformConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? employerSubscriptionMonthly = null,
    Object? employerSubscriptionWeekly = null,
    Object? employerSubscriptionDaily = null,
    Object? workerNoShowPenalty = null,
    Object? employerCancelPenalty6h = null,
    Object? employerCancelPenalty3h = null,
    Object? employerCancelPenalty1h = null,
  }) {
    return _then(_$PlatformConfigImpl(
      employerSubscriptionMonthly: null == employerSubscriptionMonthly
          ? _value.employerSubscriptionMonthly
          : employerSubscriptionMonthly // ignore: cast_nullable_to_non_nullable
              as double,
      employerSubscriptionWeekly: null == employerSubscriptionWeekly
          ? _value.employerSubscriptionWeekly
          : employerSubscriptionWeekly // ignore: cast_nullable_to_non_nullable
              as double,
      employerSubscriptionDaily: null == employerSubscriptionDaily
          ? _value.employerSubscriptionDaily
          : employerSubscriptionDaily // ignore: cast_nullable_to_non_nullable
              as double,
      workerNoShowPenalty: null == workerNoShowPenalty
          ? _value.workerNoShowPenalty
          : workerNoShowPenalty // ignore: cast_nullable_to_non_nullable
              as double,
      employerCancelPenalty6h: null == employerCancelPenalty6h
          ? _value.employerCancelPenalty6h
          : employerCancelPenalty6h // ignore: cast_nullable_to_non_nullable
              as double,
      employerCancelPenalty3h: null == employerCancelPenalty3h
          ? _value.employerCancelPenalty3h
          : employerCancelPenalty3h // ignore: cast_nullable_to_non_nullable
              as double,
      employerCancelPenalty1h: null == employerCancelPenalty1h
          ? _value.employerCancelPenalty1h
          : employerCancelPenalty1h // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlatformConfigImpl implements _PlatformConfig {
  const _$PlatformConfigImpl(
      {@JsonKey(name: 'employer_subscription_monthly')
      required this.employerSubscriptionMonthly,
      @JsonKey(name: 'employer_subscription_weekly')
      required this.employerSubscriptionWeekly,
      @JsonKey(name: 'employer_subscription_daily')
      required this.employerSubscriptionDaily,
      @JsonKey(name: 'worker_no_show_penalty')
      required this.workerNoShowPenalty,
      @JsonKey(name: 'employer_cancel_penalty_6h')
      required this.employerCancelPenalty6h,
      @JsonKey(name: 'employer_cancel_penalty_3h')
      required this.employerCancelPenalty3h,
      @JsonKey(name: 'employer_cancel_penalty_1h')
      required this.employerCancelPenalty1h});

  factory _$PlatformConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlatformConfigImplFromJson(json);

  @override
  @JsonKey(name: 'employer_subscription_monthly')
  final double employerSubscriptionMonthly;
  @override
  @JsonKey(name: 'employer_subscription_weekly')
  final double employerSubscriptionWeekly;
  @override
  @JsonKey(name: 'employer_subscription_daily')
  final double employerSubscriptionDaily;
  @override
  @JsonKey(name: 'worker_no_show_penalty')
  final double workerNoShowPenalty;
  @override
  @JsonKey(name: 'employer_cancel_penalty_6h')
  final double employerCancelPenalty6h;
  @override
  @JsonKey(name: 'employer_cancel_penalty_3h')
  final double employerCancelPenalty3h;
  @override
  @JsonKey(name: 'employer_cancel_penalty_1h')
  final double employerCancelPenalty1h;

  @override
  String toString() {
    return 'PlatformConfig(employerSubscriptionMonthly: $employerSubscriptionMonthly, employerSubscriptionWeekly: $employerSubscriptionWeekly, employerSubscriptionDaily: $employerSubscriptionDaily, workerNoShowPenalty: $workerNoShowPenalty, employerCancelPenalty6h: $employerCancelPenalty6h, employerCancelPenalty3h: $employerCancelPenalty3h, employerCancelPenalty1h: $employerCancelPenalty1h)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlatformConfigImpl &&
            (identical(other.employerSubscriptionMonthly,
                    employerSubscriptionMonthly) ||
                other.employerSubscriptionMonthly ==
                    employerSubscriptionMonthly) &&
            (identical(other.employerSubscriptionWeekly,
                    employerSubscriptionWeekly) ||
                other.employerSubscriptionWeekly ==
                    employerSubscriptionWeekly) &&
            (identical(other.employerSubscriptionDaily,
                    employerSubscriptionDaily) ||
                other.employerSubscriptionDaily == employerSubscriptionDaily) &&
            (identical(other.workerNoShowPenalty, workerNoShowPenalty) ||
                other.workerNoShowPenalty == workerNoShowPenalty) &&
            (identical(
                    other.employerCancelPenalty6h, employerCancelPenalty6h) ||
                other.employerCancelPenalty6h == employerCancelPenalty6h) &&
            (identical(
                    other.employerCancelPenalty3h, employerCancelPenalty3h) ||
                other.employerCancelPenalty3h == employerCancelPenalty3h) &&
            (identical(
                    other.employerCancelPenalty1h, employerCancelPenalty1h) ||
                other.employerCancelPenalty1h == employerCancelPenalty1h));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      employerSubscriptionMonthly,
      employerSubscriptionWeekly,
      employerSubscriptionDaily,
      workerNoShowPenalty,
      employerCancelPenalty6h,
      employerCancelPenalty3h,
      employerCancelPenalty1h);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlatformConfigImplCopyWith<_$PlatformConfigImpl> get copyWith =>
      __$$PlatformConfigImplCopyWithImpl<_$PlatformConfigImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlatformConfigImplToJson(
      this,
    );
  }
}

abstract class _PlatformConfig implements PlatformConfig {
  const factory _PlatformConfig(
      {@JsonKey(name: 'employer_subscription_monthly')
      required final double employerSubscriptionMonthly,
      @JsonKey(name: 'employer_subscription_weekly')
      required final double employerSubscriptionWeekly,
      @JsonKey(name: 'employer_subscription_daily')
      required final double employerSubscriptionDaily,
      @JsonKey(name: 'worker_no_show_penalty')
      required final double workerNoShowPenalty,
      @JsonKey(name: 'employer_cancel_penalty_6h')
      required final double employerCancelPenalty6h,
      @JsonKey(name: 'employer_cancel_penalty_3h')
      required final double employerCancelPenalty3h,
      @JsonKey(name: 'employer_cancel_penalty_1h')
      required final double employerCancelPenalty1h}) = _$PlatformConfigImpl;

  factory _PlatformConfig.fromJson(Map<String, dynamic> json) =
      _$PlatformConfigImpl.fromJson;

  @override
  @JsonKey(name: 'employer_subscription_monthly')
  double get employerSubscriptionMonthly;
  @override
  @JsonKey(name: 'employer_subscription_weekly')
  double get employerSubscriptionWeekly;
  @override
  @JsonKey(name: 'employer_subscription_daily')
  double get employerSubscriptionDaily;
  @override
  @JsonKey(name: 'worker_no_show_penalty')
  double get workerNoShowPenalty;
  @override
  @JsonKey(name: 'employer_cancel_penalty_6h')
  double get employerCancelPenalty6h;
  @override
  @JsonKey(name: 'employer_cancel_penalty_3h')
  double get employerCancelPenalty3h;
  @override
  @JsonKey(name: 'employer_cancel_penalty_1h')
  double get employerCancelPenalty1h;
  @override
  @JsonKey(ignore: true)
  _$$PlatformConfigImplCopyWith<_$PlatformConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Dispute _$DisputeFromJson(Map<String, dynamic> json) {
  return _Dispute.fromJson(json);
}

/// @nodoc
mixin _$Dispute {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'gig_id')
  String get gigId => throw _privateConstructorUsedError;
  @JsonKey(name: 'worker_name')
  String get workerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'business_name')
  String get businessName => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount_paise')
  int get amountPaise => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get resolution => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DisputeCopyWith<Dispute> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DisputeCopyWith<$Res> {
  factory $DisputeCopyWith(Dispute value, $Res Function(Dispute) then) =
      _$DisputeCopyWithImpl<$Res, Dispute>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'gig_id') String gigId,
      @JsonKey(name: 'worker_name') String workerName,
      @JsonKey(name: 'business_name') String businessName,
      @JsonKey(name: 'amount_paise') int amountPaise,
      String reason,
      String status,
      @JsonKey(name: 'created_at') DateTime createdAt,
      String? resolution});
}

/// @nodoc
class _$DisputeCopyWithImpl<$Res, $Val extends Dispute>
    implements $DisputeCopyWith<$Res> {
  _$DisputeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gigId = null,
    Object? workerName = null,
    Object? businessName = null,
    Object? amountPaise = null,
    Object? reason = null,
    Object? status = null,
    Object? createdAt = null,
    Object? resolution = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      gigId: null == gigId
          ? _value.gigId
          : gigId // ignore: cast_nullable_to_non_nullable
              as String,
      workerName: null == workerName
          ? _value.workerName
          : workerName // ignore: cast_nullable_to_non_nullable
              as String,
      businessName: null == businessName
          ? _value.businessName
          : businessName // ignore: cast_nullable_to_non_nullable
              as String,
      amountPaise: null == amountPaise
          ? _value.amountPaise
          : amountPaise // ignore: cast_nullable_to_non_nullable
              as int,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      resolution: freezed == resolution
          ? _value.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DisputeImplCopyWith<$Res> implements $DisputeCopyWith<$Res> {
  factory _$$DisputeImplCopyWith(
          _$DisputeImpl value, $Res Function(_$DisputeImpl) then) =
      __$$DisputeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'gig_id') String gigId,
      @JsonKey(name: 'worker_name') String workerName,
      @JsonKey(name: 'business_name') String businessName,
      @JsonKey(name: 'amount_paise') int amountPaise,
      String reason,
      String status,
      @JsonKey(name: 'created_at') DateTime createdAt,
      String? resolution});
}

/// @nodoc
class __$$DisputeImplCopyWithImpl<$Res>
    extends _$DisputeCopyWithImpl<$Res, _$DisputeImpl>
    implements _$$DisputeImplCopyWith<$Res> {
  __$$DisputeImplCopyWithImpl(
      _$DisputeImpl _value, $Res Function(_$DisputeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gigId = null,
    Object? workerName = null,
    Object? businessName = null,
    Object? amountPaise = null,
    Object? reason = null,
    Object? status = null,
    Object? createdAt = null,
    Object? resolution = freezed,
  }) {
    return _then(_$DisputeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      gigId: null == gigId
          ? _value.gigId
          : gigId // ignore: cast_nullable_to_non_nullable
              as String,
      workerName: null == workerName
          ? _value.workerName
          : workerName // ignore: cast_nullable_to_non_nullable
              as String,
      businessName: null == businessName
          ? _value.businessName
          : businessName // ignore: cast_nullable_to_non_nullable
              as String,
      amountPaise: null == amountPaise
          ? _value.amountPaise
          : amountPaise // ignore: cast_nullable_to_non_nullable
              as int,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      resolution: freezed == resolution
          ? _value.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DisputeImpl implements _Dispute {
  const _$DisputeImpl(
      {required this.id,
      @JsonKey(name: 'gig_id') required this.gigId,
      @JsonKey(name: 'worker_name') required this.workerName,
      @JsonKey(name: 'business_name') required this.businessName,
      @JsonKey(name: 'amount_paise') required this.amountPaise,
      required this.reason,
      required this.status,
      @JsonKey(name: 'created_at') required this.createdAt,
      this.resolution});

  factory _$DisputeImpl.fromJson(Map<String, dynamic> json) =>
      _$$DisputeImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'gig_id')
  final String gigId;
  @override
  @JsonKey(name: 'worker_name')
  final String workerName;
  @override
  @JsonKey(name: 'business_name')
  final String businessName;
  @override
  @JsonKey(name: 'amount_paise')
  final int amountPaise;
  @override
  final String reason;
  @override
  final String status;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  final String? resolution;

  @override
  String toString() {
    return 'Dispute(id: $id, gigId: $gigId, workerName: $workerName, businessName: $businessName, amountPaise: $amountPaise, reason: $reason, status: $status, createdAt: $createdAt, resolution: $resolution)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DisputeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.gigId, gigId) || other.gigId == gigId) &&
            (identical(other.workerName, workerName) ||
                other.workerName == workerName) &&
            (identical(other.businessName, businessName) ||
                other.businessName == businessName) &&
            (identical(other.amountPaise, amountPaise) ||
                other.amountPaise == amountPaise) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.resolution, resolution) ||
                other.resolution == resolution));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, gigId, workerName,
      businessName, amountPaise, reason, status, createdAt, resolution);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DisputeImplCopyWith<_$DisputeImpl> get copyWith =>
      __$$DisputeImplCopyWithImpl<_$DisputeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DisputeImplToJson(
      this,
    );
  }
}

abstract class _Dispute implements Dispute {
  const factory _Dispute(
      {required final String id,
      @JsonKey(name: 'gig_id') required final String gigId,
      @JsonKey(name: 'worker_name') required final String workerName,
      @JsonKey(name: 'business_name') required final String businessName,
      @JsonKey(name: 'amount_paise') required final int amountPaise,
      required final String reason,
      required final String status,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      final String? resolution}) = _$DisputeImpl;

  factory _Dispute.fromJson(Map<String, dynamic> json) = _$DisputeImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'gig_id')
  String get gigId;
  @override
  @JsonKey(name: 'worker_name')
  String get workerName;
  @override
  @JsonKey(name: 'business_name')
  String get businessName;
  @override
  @JsonKey(name: 'amount_paise')
  int get amountPaise;
  @override
  String get reason;
  @override
  String get status;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  String? get resolution;
  @override
  @JsonKey(ignore: true)
  _$$DisputeImplCopyWith<_$DisputeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AnalyticsOverview _$AnalyticsOverviewFromJson(Map<String, dynamic> json) {
  return _AnalyticsOverview.fromJson(json);
}

/// @nodoc
mixin _$AnalyticsOverview {
  @JsonKey(name: 'total_gigs')
  int get totalGigs => throw _privateConstructorUsedError;
  @JsonKey(name: 'active_workers')
  int get activeWorkers => throw _privateConstructorUsedError;
  @JsonKey(name: 'active_businesses')
  int get activeBusinesses => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_revenue_paise')
  int get totalRevenuePaise => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AnalyticsOverviewCopyWith<AnalyticsOverview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnalyticsOverviewCopyWith<$Res> {
  factory $AnalyticsOverviewCopyWith(
          AnalyticsOverview value, $Res Function(AnalyticsOverview) then) =
      _$AnalyticsOverviewCopyWithImpl<$Res, AnalyticsOverview>;
  @useResult
  $Res call(
      {@JsonKey(name: 'total_gigs') int totalGigs,
      @JsonKey(name: 'active_workers') int activeWorkers,
      @JsonKey(name: 'active_businesses') int activeBusinesses,
      @JsonKey(name: 'total_revenue_paise') int totalRevenuePaise});
}

/// @nodoc
class _$AnalyticsOverviewCopyWithImpl<$Res, $Val extends AnalyticsOverview>
    implements $AnalyticsOverviewCopyWith<$Res> {
  _$AnalyticsOverviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalGigs = null,
    Object? activeWorkers = null,
    Object? activeBusinesses = null,
    Object? totalRevenuePaise = null,
  }) {
    return _then(_value.copyWith(
      totalGigs: null == totalGigs
          ? _value.totalGigs
          : totalGigs // ignore: cast_nullable_to_non_nullable
              as int,
      activeWorkers: null == activeWorkers
          ? _value.activeWorkers
          : activeWorkers // ignore: cast_nullable_to_non_nullable
              as int,
      activeBusinesses: null == activeBusinesses
          ? _value.activeBusinesses
          : activeBusinesses // ignore: cast_nullable_to_non_nullable
              as int,
      totalRevenuePaise: null == totalRevenuePaise
          ? _value.totalRevenuePaise
          : totalRevenuePaise // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AnalyticsOverviewImplCopyWith<$Res>
    implements $AnalyticsOverviewCopyWith<$Res> {
  factory _$$AnalyticsOverviewImplCopyWith(_$AnalyticsOverviewImpl value,
          $Res Function(_$AnalyticsOverviewImpl) then) =
      __$$AnalyticsOverviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'total_gigs') int totalGigs,
      @JsonKey(name: 'active_workers') int activeWorkers,
      @JsonKey(name: 'active_businesses') int activeBusinesses,
      @JsonKey(name: 'total_revenue_paise') int totalRevenuePaise});
}

/// @nodoc
class __$$AnalyticsOverviewImplCopyWithImpl<$Res>
    extends _$AnalyticsOverviewCopyWithImpl<$Res, _$AnalyticsOverviewImpl>
    implements _$$AnalyticsOverviewImplCopyWith<$Res> {
  __$$AnalyticsOverviewImplCopyWithImpl(_$AnalyticsOverviewImpl _value,
      $Res Function(_$AnalyticsOverviewImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalGigs = null,
    Object? activeWorkers = null,
    Object? activeBusinesses = null,
    Object? totalRevenuePaise = null,
  }) {
    return _then(_$AnalyticsOverviewImpl(
      totalGigs: null == totalGigs
          ? _value.totalGigs
          : totalGigs // ignore: cast_nullable_to_non_nullable
              as int,
      activeWorkers: null == activeWorkers
          ? _value.activeWorkers
          : activeWorkers // ignore: cast_nullable_to_non_nullable
              as int,
      activeBusinesses: null == activeBusinesses
          ? _value.activeBusinesses
          : activeBusinesses // ignore: cast_nullable_to_non_nullable
              as int,
      totalRevenuePaise: null == totalRevenuePaise
          ? _value.totalRevenuePaise
          : totalRevenuePaise // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AnalyticsOverviewImpl implements _AnalyticsOverview {
  const _$AnalyticsOverviewImpl(
      {@JsonKey(name: 'total_gigs') required this.totalGigs,
      @JsonKey(name: 'active_workers') required this.activeWorkers,
      @JsonKey(name: 'active_businesses') required this.activeBusinesses,
      @JsonKey(name: 'total_revenue_paise') required this.totalRevenuePaise});

  factory _$AnalyticsOverviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnalyticsOverviewImplFromJson(json);

  @override
  @JsonKey(name: 'total_gigs')
  final int totalGigs;
  @override
  @JsonKey(name: 'active_workers')
  final int activeWorkers;
  @override
  @JsonKey(name: 'active_businesses')
  final int activeBusinesses;
  @override
  @JsonKey(name: 'total_revenue_paise')
  final int totalRevenuePaise;

  @override
  String toString() {
    return 'AnalyticsOverview(totalGigs: $totalGigs, activeWorkers: $activeWorkers, activeBusinesses: $activeBusinesses, totalRevenuePaise: $totalRevenuePaise)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnalyticsOverviewImpl &&
            (identical(other.totalGigs, totalGigs) ||
                other.totalGigs == totalGigs) &&
            (identical(other.activeWorkers, activeWorkers) ||
                other.activeWorkers == activeWorkers) &&
            (identical(other.activeBusinesses, activeBusinesses) ||
                other.activeBusinesses == activeBusinesses) &&
            (identical(other.totalRevenuePaise, totalRevenuePaise) ||
                other.totalRevenuePaise == totalRevenuePaise));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, totalGigs, activeWorkers,
      activeBusinesses, totalRevenuePaise);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AnalyticsOverviewImplCopyWith<_$AnalyticsOverviewImpl> get copyWith =>
      __$$AnalyticsOverviewImplCopyWithImpl<_$AnalyticsOverviewImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnalyticsOverviewImplToJson(
      this,
    );
  }
}

abstract class _AnalyticsOverview implements AnalyticsOverview {
  const factory _AnalyticsOverview(
      {@JsonKey(name: 'total_gigs') required final int totalGigs,
      @JsonKey(name: 'active_workers') required final int activeWorkers,
      @JsonKey(name: 'active_businesses') required final int activeBusinesses,
      @JsonKey(name: 'total_revenue_paise')
      required final int totalRevenuePaise}) = _$AnalyticsOverviewImpl;

  factory _AnalyticsOverview.fromJson(Map<String, dynamic> json) =
      _$AnalyticsOverviewImpl.fromJson;

  @override
  @JsonKey(name: 'total_gigs')
  int get totalGigs;
  @override
  @JsonKey(name: 'active_workers')
  int get activeWorkers;
  @override
  @JsonKey(name: 'active_businesses')
  int get activeBusinesses;
  @override
  @JsonKey(name: 'total_revenue_paise')
  int get totalRevenuePaise;
  @override
  @JsonKey(ignore: true)
  _$$AnalyticsOverviewImplCopyWith<_$AnalyticsOverviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FinancialMetrics _$FinancialMetricsFromJson(Map<String, dynamic> json) {
  return _FinancialMetrics.fromJson(json);
}

/// @nodoc
mixin _$FinancialMetrics {
  @JsonKey(name: 'escrow_balance_paise')
  int get escrowBalancePaise => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_payouts_paise')
  int get totalPayoutsPaise => throw _privateConstructorUsedError;
  @JsonKey(name: 'commission_earned_paise')
  int get commissionEarnedPaise => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FinancialMetricsCopyWith<FinancialMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FinancialMetricsCopyWith<$Res> {
  factory $FinancialMetricsCopyWith(
          FinancialMetrics value, $Res Function(FinancialMetrics) then) =
      _$FinancialMetricsCopyWithImpl<$Res, FinancialMetrics>;
  @useResult
  $Res call(
      {@JsonKey(name: 'escrow_balance_paise') int escrowBalancePaise,
      @JsonKey(name: 'total_payouts_paise') int totalPayoutsPaise,
      @JsonKey(name: 'commission_earned_paise') int commissionEarnedPaise});
}

/// @nodoc
class _$FinancialMetricsCopyWithImpl<$Res, $Val extends FinancialMetrics>
    implements $FinancialMetricsCopyWith<$Res> {
  _$FinancialMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? escrowBalancePaise = null,
    Object? totalPayoutsPaise = null,
    Object? commissionEarnedPaise = null,
  }) {
    return _then(_value.copyWith(
      escrowBalancePaise: null == escrowBalancePaise
          ? _value.escrowBalancePaise
          : escrowBalancePaise // ignore: cast_nullable_to_non_nullable
              as int,
      totalPayoutsPaise: null == totalPayoutsPaise
          ? _value.totalPayoutsPaise
          : totalPayoutsPaise // ignore: cast_nullable_to_non_nullable
              as int,
      commissionEarnedPaise: null == commissionEarnedPaise
          ? _value.commissionEarnedPaise
          : commissionEarnedPaise // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FinancialMetricsImplCopyWith<$Res>
    implements $FinancialMetricsCopyWith<$Res> {
  factory _$$FinancialMetricsImplCopyWith(_$FinancialMetricsImpl value,
          $Res Function(_$FinancialMetricsImpl) then) =
      __$$FinancialMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'escrow_balance_paise') int escrowBalancePaise,
      @JsonKey(name: 'total_payouts_paise') int totalPayoutsPaise,
      @JsonKey(name: 'commission_earned_paise') int commissionEarnedPaise});
}

/// @nodoc
class __$$FinancialMetricsImplCopyWithImpl<$Res>
    extends _$FinancialMetricsCopyWithImpl<$Res, _$FinancialMetricsImpl>
    implements _$$FinancialMetricsImplCopyWith<$Res> {
  __$$FinancialMetricsImplCopyWithImpl(_$FinancialMetricsImpl _value,
      $Res Function(_$FinancialMetricsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? escrowBalancePaise = null,
    Object? totalPayoutsPaise = null,
    Object? commissionEarnedPaise = null,
  }) {
    return _then(_$FinancialMetricsImpl(
      escrowBalancePaise: null == escrowBalancePaise
          ? _value.escrowBalancePaise
          : escrowBalancePaise // ignore: cast_nullable_to_non_nullable
              as int,
      totalPayoutsPaise: null == totalPayoutsPaise
          ? _value.totalPayoutsPaise
          : totalPayoutsPaise // ignore: cast_nullable_to_non_nullable
              as int,
      commissionEarnedPaise: null == commissionEarnedPaise
          ? _value.commissionEarnedPaise
          : commissionEarnedPaise // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FinancialMetricsImpl implements _FinancialMetrics {
  const _$FinancialMetricsImpl(
      {@JsonKey(name: 'escrow_balance_paise') required this.escrowBalancePaise,
      @JsonKey(name: 'total_payouts_paise') required this.totalPayoutsPaise,
      @JsonKey(name: 'commission_earned_paise')
      required this.commissionEarnedPaise});

  factory _$FinancialMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$FinancialMetricsImplFromJson(json);

  @override
  @JsonKey(name: 'escrow_balance_paise')
  final int escrowBalancePaise;
  @override
  @JsonKey(name: 'total_payouts_paise')
  final int totalPayoutsPaise;
  @override
  @JsonKey(name: 'commission_earned_paise')
  final int commissionEarnedPaise;

  @override
  String toString() {
    return 'FinancialMetrics(escrowBalancePaise: $escrowBalancePaise, totalPayoutsPaise: $totalPayoutsPaise, commissionEarnedPaise: $commissionEarnedPaise)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FinancialMetricsImpl &&
            (identical(other.escrowBalancePaise, escrowBalancePaise) ||
                other.escrowBalancePaise == escrowBalancePaise) &&
            (identical(other.totalPayoutsPaise, totalPayoutsPaise) ||
                other.totalPayoutsPaise == totalPayoutsPaise) &&
            (identical(other.commissionEarnedPaise, commissionEarnedPaise) ||
                other.commissionEarnedPaise == commissionEarnedPaise));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, escrowBalancePaise,
      totalPayoutsPaise, commissionEarnedPaise);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FinancialMetricsImplCopyWith<_$FinancialMetricsImpl> get copyWith =>
      __$$FinancialMetricsImplCopyWithImpl<_$FinancialMetricsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FinancialMetricsImplToJson(
      this,
    );
  }
}

abstract class _FinancialMetrics implements FinancialMetrics {
  const factory _FinancialMetrics(
      {@JsonKey(name: 'escrow_balance_paise')
      required final int escrowBalancePaise,
      @JsonKey(name: 'total_payouts_paise')
      required final int totalPayoutsPaise,
      @JsonKey(name: 'commission_earned_paise')
      required final int commissionEarnedPaise}) = _$FinancialMetricsImpl;

  factory _FinancialMetrics.fromJson(Map<String, dynamic> json) =
      _$FinancialMetricsImpl.fromJson;

  @override
  @JsonKey(name: 'escrow_balance_paise')
  int get escrowBalancePaise;
  @override
  @JsonKey(name: 'total_payouts_paise')
  int get totalPayoutsPaise;
  @override
  @JsonKey(name: 'commission_earned_paise')
  int get commissionEarnedPaise;
  @override
  @JsonKey(ignore: true)
  _$$FinancialMetricsImplCopyWith<_$FinancialMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Expenditure _$ExpenditureFromJson(Map<String, dynamic> json) {
  return _Expenditure.fromJson(json);
}

/// @nodoc
mixin _$Expenditure {
  String get id => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // RENT, SALARY, MARKETING, CLOUD, etc.
  @JsonKey(name: 'amount_paise')
  int get amountPaise => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExpenditureCopyWith<Expenditure> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpenditureCopyWith<$Res> {
  factory $ExpenditureCopyWith(
          Expenditure value, $Res Function(Expenditure) then) =
      _$ExpenditureCopyWithImpl<$Res, Expenditure>;
  @useResult
  $Res call(
      {String id,
      String type,
      @JsonKey(name: 'amount_paise') int amountPaise,
      String description,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$ExpenditureCopyWithImpl<$Res, $Val extends Expenditure>
    implements $ExpenditureCopyWith<$Res> {
  _$ExpenditureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? amountPaise = null,
    Object? description = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      amountPaise: null == amountPaise
          ? _value.amountPaise
          : amountPaise // ignore: cast_nullable_to_non_nullable
              as int,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExpenditureImplCopyWith<$Res>
    implements $ExpenditureCopyWith<$Res> {
  factory _$$ExpenditureImplCopyWith(
          _$ExpenditureImpl value, $Res Function(_$ExpenditureImpl) then) =
      __$$ExpenditureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      @JsonKey(name: 'amount_paise') int amountPaise,
      String description,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$ExpenditureImplCopyWithImpl<$Res>
    extends _$ExpenditureCopyWithImpl<$Res, _$ExpenditureImpl>
    implements _$$ExpenditureImplCopyWith<$Res> {
  __$$ExpenditureImplCopyWithImpl(
      _$ExpenditureImpl _value, $Res Function(_$ExpenditureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? amountPaise = null,
    Object? description = null,
    Object? createdAt = null,
  }) {
    return _then(_$ExpenditureImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      amountPaise: null == amountPaise
          ? _value.amountPaise
          : amountPaise // ignore: cast_nullable_to_non_nullable
              as int,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExpenditureImpl implements _Expenditure {
  const _$ExpenditureImpl(
      {required this.id,
      required this.type,
      @JsonKey(name: 'amount_paise') required this.amountPaise,
      required this.description,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$ExpenditureImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExpenditureImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
// RENT, SALARY, MARKETING, CLOUD, etc.
  @override
  @JsonKey(name: 'amount_paise')
  final int amountPaise;
  @override
  final String description;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'Expenditure(id: $id, type: $type, amountPaise: $amountPaise, description: $description, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpenditureImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.amountPaise, amountPaise) ||
                other.amountPaise == amountPaise) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, type, amountPaise, description, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpenditureImplCopyWith<_$ExpenditureImpl> get copyWith =>
      __$$ExpenditureImplCopyWithImpl<_$ExpenditureImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExpenditureImplToJson(
      this,
    );
  }
}

abstract class _Expenditure implements Expenditure {
  const factory _Expenditure(
          {required final String id,
          required final String type,
          @JsonKey(name: 'amount_paise') required final int amountPaise,
          required final String description,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$ExpenditureImpl;

  factory _Expenditure.fromJson(Map<String, dynamic> json) =
      _$ExpenditureImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override // RENT, SALARY, MARKETING, CLOUD, etc.
  @JsonKey(name: 'amount_paise')
  int get amountPaise;
  @override
  String get description;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$ExpenditureImplCopyWith<_$ExpenditureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
