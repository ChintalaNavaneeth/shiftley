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

  // Management Users
  Future<List<ManagementUser>> getManagementUsers() async {
    final response = await _client.dio.get('/admin/users');
    if (response.statusCode == 200) {
      final List data = response.data['data'];
      return data.map((json) => ManagementUser.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch management users');
  }

  Future<ManagementUser> createManagementUser(String fullName, String email, String phoneNumber, String role) async {
    final response = await _client.dio.post('/admin/super/users', data: {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'role': role,
    });
    if (response.statusCode == 201 || response.statusCode == 200) {
      return ManagementUser.fromJson(response.data['data']);
    }
    throw Exception('Failed to create management user');
  }

  Future<void> updateUserStatus(String id, String status) async {
    final response = await _client.dio.patch('/admin/users/$id/status', data: {
      'status': status,
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to update user status');
    }
  }

  // Platform Config
  Future<PlatformConfig> getPlatformConfig() async {
    final response = await _client.dio.get('/admin/config');
    if (response.statusCode == 200) {
      return PlatformConfig.fromJson(response.data['data']);
    }
    throw Exception('Failed to fetch platform config');
  }

  Future<void> updatePlatformConfig(double feePercentage) async {
    final response = await _client.dio.patch('/admin/config/fees', data: {
      'fee_percentage': feePercentage,
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to update platform config');
    }
  }

  // Disputes
  Future<List<Dispute>> getPendingDisputes() async {
    final response = await _client.dio.get('/admin/disputes/pending');
    if (response.statusCode == 200) {
      final List data = response.data['data'];
      return data.map((json) => Dispute.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch pending disputes');
  }

  Future<void> resolveDispute(String id, String resolution, String notes) async {
    final response = await _client.dio.post('/admin/disputes/$id/resolve', data: {
      'resolution': resolution,
      'notes': notes,
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to resolve dispute');
    }
  }

  // Analytics
  Future<AnalyticsOverview> getAnalyticsOverview() async {
    final response = await _client.dio.get('/analytics/overview');
    if (response.statusCode == 200) {
      return AnalyticsOverview.fromJson(response.data['data']);
    }
    throw Exception('Failed to fetch analytics overview');
  }

  Future<FinancialMetrics> getFinancials() async {
    final response = await _client.dio.get('/analytics/financials');
    if (response.statusCode == 200) {
      return FinancialMetrics.fromJson(response.data['data']);
    }
    throw Exception('Failed to fetch financials');
  }

  Future<void> logExpenditure(String type, int amountPaise, String description) async {
    final response = await _client.dio.post('/analytics/expenditure', data: {
      'type': type,
      'amount_paise': amountPaise,
      'description': description,
    });
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to log expenditure');
    }
  }
}

@riverpod
AdminRepository adminRepository(AdminRepositoryRef ref) {
  final client = ref.watch(apiClientProvider);
  return AdminRepository(client);
}
