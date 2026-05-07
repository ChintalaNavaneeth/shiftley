import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_models.freezed.dart';
part 'admin_models.g.dart';

@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    @JsonKey(name: 'is_active') required bool isActive,
    @Default([]) List<Skill> skills,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
}

@freezed
class Skill with _$Skill {
  const factory Skill({
    required String id,
    @JsonKey(name: 'category_id') required String categoryId,
    required String name,
    @JsonKey(name: 'is_active') required bool isActive,
  }) = _Skill;

  factory Skill.fromJson(Map<String, dynamic> json) => _$SkillFromJson(json);
}
