class TaxonomySkill {
  final String id;
  final String name;
  final String categoryId;

  TaxonomySkill({required this.id, required this.name, required this.categoryId});

  factory TaxonomySkill.fromJson(Map<String, dynamic> json) {
    return TaxonomySkill(
      id: json['id'] as String,
      name: json['name'] as String,
      categoryId: json['category_id'] as String,
    );
  }
}

class TaxonomyCategory {
  final String id;
  final String name;
  final List<TaxonomySkill> skills;

  TaxonomyCategory({required this.id, required this.name, required this.skills});

  factory TaxonomyCategory.fromJson(Map<String, dynamic> json) {
    final skillsList = (json['skills'] as List<dynamic>? ?? [])
        .map((s) => TaxonomySkill.fromJson(s as Map<String, dynamic>))
        .toList();
    return TaxonomyCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      skills: skillsList,
    );
  }
}
