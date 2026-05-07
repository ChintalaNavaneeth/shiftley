import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_providers.dart';
import '../domain/admin_models.dart';

part 'admin_repository.g.dart';

class AdminRepository {
  final ApiClient _client;

  AdminRepository(this._client);

  Future<List<Category>> getAdminTaxonomy() async {
    final response = await _client.dio.get('/admin/taxonomy/categories');
    if (response.statusCode == 200) {
      final List data = response.data['data'];
      return data.map((json) => Category.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch admin taxonomy');
  }

  Future<Category> createCategory(String name) async {
    final response = await _client.dio.post('/admin/taxonomy/categories', data: {
      'name': name,
    });
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Category.fromJson(response.data['data']);
    }
    throw Exception('Failed to create category');
  }

  Future<Category> updateCategory(String id, {String? name, bool? isActive}) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (isActive != null) data['is_active'] = isActive;

    final response = await _client.dio.patch('/admin/taxonomy/categories/$id', data: data);
    if (response.statusCode == 200) {
      return Category.fromJson(response.data['data']);
    }
    throw Exception('Failed to update category');
  }

  Future<Skill> createSkill(String categoryId, String name) async {
    final response = await _client.dio.post('/admin/taxonomy/categories/$categoryId/skills', data: {
      'name': name,
    });
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Skill.fromJson(response.data['data']);
    }
    throw Exception('Failed to create skill');
  }

  Future<Skill> updateSkill(String id, {String? name, bool? isActive}) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (isActive != null) data['is_active'] = isActive;

    final response = await _client.dio.patch('/admin/taxonomy/skills/$id', data: data);
    if (response.statusCode == 200) {
      return Skill.fromJson(response.data['data']);
    }
    throw Exception('Failed to update skill');
  }

  Future<void> updateSuperAdminSetup(String fullName, String email, String phoneNumber) async {
    final response = await _client.dio.patch('/admin/super/setup', data: {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
    });
    if (response.statusCode != 200) {
      throw Exception(response.data['message'] ?? 'Failed to update super admin setup');
    }
  }
}

@riverpod
AdminRepository adminRepository(AdminRepositoryRef ref) {
  final client = ref.watch(apiClientProvider);
  return AdminRepository(client);
}
