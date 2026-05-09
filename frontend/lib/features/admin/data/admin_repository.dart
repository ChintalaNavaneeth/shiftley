import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_providers.dart';
import '../domain/admin_models.dart';

class AdminRepository {
  final ApiClient _client;

  AdminRepository(this._client);

  Future<List<Category>> getAdminTaxonomy() async {
    final response = await _client.dio.get('admin/taxonomy/categories');
    if (response.statusCode == 200) {
      final List data = response.data['data'];
      return data.map((json) => Category.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch admin taxonomy');
  }

  Future<Category> createCategory(String name) async {
    final response = await _client.dio.post('admin/taxonomy/categories', data: {
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

    final response = await _client.dio.patch('admin/taxonomy/categories/$id', data: data);
    if (response.statusCode == 200) {
      return Category.fromJson(response.data['data']);
    }
    throw Exception('Failed to update category');
  }

  Future<Skill> createSkill(String categoryId, String name) async {
    final response = await _client.dio.post('admin/taxonomy/categories/$categoryId/skills', data: {
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

    final response = await _client.dio.patch('admin/taxonomy/skills/$id', data: data);
    if (response.statusCode == 200) {
      return Skill.fromJson(response.data['data']);
    }
    throw Exception('Failed to update skill');
  }

  Future<void> updateSuperAdminSetup(String fullName, String email, String phoneNumber) async {
    final response = await _client.dio.patch('admin/super/setup', data: {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
    });
    if (response.statusCode != 200) {
      throw Exception(response.data['message'] ?? 'Failed to update super admin setup');
    }
  }

  // Management Users
  Future<List<ManagementUser>> getManagementUsers({String? query, String? role, String? status}) async {
    final response = await _client.dio.get(
      'admin/users',
      queryParameters: {
        if (query != null && query.isNotEmpty) 'query': query,
        if (role != null && role != 'All Roles') 'role': role,
        if (status != null && status != 'All Status') 'status': status,
      },
    );
    if (response.statusCode == 200) {
      final data = response.data['data'];
      if (data == null) return [];
      final List list = data;
      return list.map((json) => ManagementUser.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch management users');
  }

  Future<String> createManagementUser(String fullName, String email, String phoneNumber, String role) async {
    final response = await _client.dio.post('admin/super/users', data: {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'role': role,
    });
    if (response.statusCode == 201 || response.statusCode == 200) {
      return response.data['data']['message'] ?? 'User created successfully';
    }
    throw Exception('Failed to create management user');
  }

  Future<void> updateManagementUser(String id, {String? fullName, String? role, String? email, String? phoneNumber}) async {
    final response = await _client.dio.patch('admin/users/$id', data: {
      'full_name': fullName,
      'role': role,
      'email': email,
      'phone_number': phoneNumber,
    }..removeWhere((_, value) => value == null));
    if (response.statusCode != 200) {
      throw Exception(response.data['message'] ?? 'Failed to update user');
    }
  }

  Future<void> deleteManagementUser(String id) async {
    final response = await _client.dio.delete('admin/users/$id');
    if (response.statusCode != 200) {
      throw Exception(response.data['message'] ?? 'Failed to delete user');
    }
  }

  Future<void> updateUserStatus(String id, String status) async {
    final response = await _client.dio.patch('admin/users/$id/status', data: {
      'status': status,
    });
    if (response.statusCode != 200) {
      throw Exception(response.data['message'] ?? 'Failed to update user status');
    }
  }

  Future<PlatformConfig> getPlatformConfig() async {
    final response = await _client.dio.get('admin/config');
    if (response.statusCode == 200) {
      return PlatformConfig.fromJson(response.data['data']);
    }
    throw Exception('Failed to fetch platform config');
  }

  Future<void> updatePlatformConfig({
    double? employerSubscriptionMonthly,
    double? employerSubscriptionWeekly,
    double? employerSubscriptionDaily,
    double? workerNoShowPenalty,
    double? employerCancelPenalty6h,
    double? employerCancelPenalty3h,
    double? employerCancelPenalty1h,
  }) async {
    final response = await _client.dio.patch('admin/config', data: {
      'employer_subscription_monthly': employerSubscriptionMonthly,
      'employer_subscription_weekly': employerSubscriptionWeekly,
      'employer_subscription_daily': employerSubscriptionDaily,
      'worker_no_show_penalty': workerNoShowPenalty,
      'employer_cancel_penalty_6h': employerCancelPenalty6h,
      'employer_cancel_penalty_3h': employerCancelPenalty3h,
      'employer_cancel_penalty_1h': employerCancelPenalty1h,
    }..removeWhere((_, value) => value == null));
    if (response.statusCode != 200) {
      throw Exception('Failed to update platform config');
    }
  }

  // Analytics & Financials
  Future<AnalyticsOverview> getAnalyticsOverview() async {
    final response = await _client.dio.get('analytics/overview');
    if (response.statusCode == 200) {
      return AnalyticsOverview.fromJson(response.data['data']);
    }
    throw Exception('Failed to fetch analytics');
  }

  Future<FinancialMetrics> getFinancials() async {
    final response = await _client.dio.get('analytics/financials');
    if (response.statusCode == 200) {
      return FinancialMetrics.fromJson(response.data['data']);
    }
    throw Exception('Failed to fetch financial metrics');
  }

  // Disputes
  Future<List<Dispute>> getPendingDisputes() async {
    final response = await _client.dio.get('admin/disputes/pending');
    if (response.statusCode == 200) {
      final List data = response.data['data'];
      return data.map((json) => Dispute.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch disputes');
  }

  Future<void> resolveDispute(String id, String resolution, String notes) async {
    final response = await _client.dio.post('admin/disputes/$id/resolve', data: {
      'resolution': resolution,
      'notes': notes,
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to resolve dispute');
    }
  }

  Future<PnLSummary> getPnL(String month) async {
    final response = await _client.dio.get('analytics/pnl', queryParameters: {'month': month});
    if (response.statusCode == 200) {
      return PnLSummary.fromJson(response.data['data']);
    }
    throw Exception('Failed to fetch PnL');
  }

  Future<LiquidityMetrics> getLiquidity() async {
    final response = await _client.dio.get('analytics/liquidity');
    if (response.statusCode == 200) {
      return LiquidityMetrics.fromJson(response.data['data']);
    }
    throw Exception('Failed to fetch liquidity');
  }

  Future<PlatformHealth> getHealth() async {
    final response = await _client.dio.get('analytics/health');
    if (response.statusCode == 200) {
      return PlatformHealth.fromJson(response.data['data']);
    }
    throw Exception('Failed to fetch health metrics');
  }

  Future<void> logExpenditure(String type, int amountPaise, String description) async {
    final response = await _client.dio.post('analytics/expenditure', data: {
      'type': type,
      'amount_paise': amountPaise,
      'description': description,
    });
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to log expenditure');
    }
  }
}

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return AdminRepository(client);
});
