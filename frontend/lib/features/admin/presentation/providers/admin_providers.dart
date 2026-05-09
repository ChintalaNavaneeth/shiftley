import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/admin_repository.dart';
import '../../domain/admin_models.dart';

// Manual Notifiers and Providers to avoid build_runner reliance and conflicts

class AdminTaxonomy extends AsyncNotifier<List<Category>> {
  @override
  FutureOr<List<Category>> build() async {
    final repo = ref.watch(adminRepositoryProvider);
    return await repo.getAdminTaxonomy();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(adminRepositoryProvider);
      return await repo.getAdminTaxonomy();
    });
  }

  Future<void> createCategory(String name) async {
    final repo = ref.read(adminRepositoryProvider);
    await repo.createCategory(name);
    await refresh();
  }

  Future<void> updateCategory(String id, {String? name, bool? isActive}) async {
    final repo = ref.read(adminRepositoryProvider);
    await repo.updateCategory(id, name: name, isActive: isActive);
    await refresh();
  }

  Future<void> createSkill(String categoryId, String name) async {
    final repo = ref.read(adminRepositoryProvider);
    await repo.createSkill(categoryId, name);
    await refresh();
  }

  Future<void> updateSkill(String id, {String? name, bool? isActive}) async {
    final repo = ref.read(adminRepositoryProvider);
    await repo.updateSkill(id, name: name, isActive: isActive);
    await refresh();
  }
}

final adminTaxonomyProvider = AsyncNotifierProvider<AdminTaxonomy, List<Category>>(AdminTaxonomy.new);

final managementSearchQueryProvider = StateProvider<String>((ref) => "");
final managementRoleFilterProvider = StateProvider<String>((ref) => "All Roles");
final managementStatusFilterProvider = StateProvider<String>((ref) => "All Status");

class ManagementUsers extends AsyncNotifier<List<ManagementUser>> {
  @override
  FutureOr<List<ManagementUser>> build() async {
    // Initial fetch with default (empty) filters
    return await ref.read(adminRepositoryProvider).getManagementUsers();
  }

  Future<void> fetchWithFilters({String query = '', String role = 'All Roles', String status = 'All Status'}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(adminRepositoryProvider).getManagementUsers(
          query: query,
          role: role,
          status: status,
        ));
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(adminRepositoryProvider).getManagementUsers());
  }

  Future<String> inviteStaff(String fullName, String email, String phone, String role) async {
    final message = await ref.read(adminRepositoryProvider).createManagementUser(fullName, email, phone, role);
    await refresh();
    return message;
  }

  Future<void> updateStatus(String id, String status) async {
    await ref.read(adminRepositoryProvider).updateUserStatus(id, status);
    await refresh();
  }

  Future<void> editUser(String id, {String? fullName, String? role, String? email, String? phoneNumber}) async {
    await ref.read(adminRepositoryProvider).updateManagementUser(id, 
      fullName: fullName, 
      role: role,
      email: email,
      phoneNumber: phoneNumber,
    );
    await refresh();
  }

  Future<void> deleteUser(String id) async {
    await ref.read(adminRepositoryProvider).deleteManagementUser(id);
    await refresh();
  }
}

final managementUsersProvider = AsyncNotifierProvider<ManagementUsers, List<ManagementUser>>(ManagementUsers.new);

class PlatformConfigNotifier extends AsyncNotifier<PlatformConfig> {
  @override
  FutureOr<PlatformConfig> build() async {
    return await ref.watch(adminRepositoryProvider).getPlatformConfig();
  }

  Future<void> updateConfig({
    double? employerSubscriptionMonthly,
    double? employerSubscriptionWeekly,
    double? employerSubscriptionDaily,
    double? workerNoShowPenalty,
    double? employerCancelPenalty6h,
    double? employerCancelPenalty3h,
    double? employerCancelPenalty1h,
  }) async {
    await ref.read(adminRepositoryProvider).updatePlatformConfig(
          employerSubscriptionMonthly: employerSubscriptionMonthly,
          employerSubscriptionWeekly: employerSubscriptionWeekly,
          employerSubscriptionDaily: employerSubscriptionDaily,
          workerNoShowPenalty: workerNoShowPenalty,
          employerCancelPenalty6h: employerCancelPenalty6h,
          employerCancelPenalty3h: employerCancelPenalty3h,
          employerCancelPenalty1h: employerCancelPenalty1h,
        );
    state = await AsyncValue.guard(() => ref.read(adminRepositoryProvider).getPlatformConfig());
  }
}

final platformConfigNotifierProvider = AsyncNotifierProvider<PlatformConfigNotifier, PlatformConfig>(PlatformConfigNotifier.new);

class PendingDisputes extends AsyncNotifier<List<Dispute>> {
  @override
  FutureOr<List<Dispute>> build() async {
    return await ref.watch(adminRepositoryProvider).getPendingDisputes();
  }

  Future<void> resolve(String id, String resolution, String notes) async {
    await ref.read(adminRepositoryProvider).resolveDispute(id, resolution, notes);
    state = await AsyncValue.guard(() => ref.read(adminRepositoryProvider).getPendingDisputes());
  }
}

final pendingDisputesProvider = AsyncNotifierProvider<PendingDisputes, List<Dispute>>(PendingDisputes.new);

final analyticsOverviewProvider = FutureProvider<AnalyticsOverview>((ref) async {
  return await ref.watch(adminRepositoryProvider).getAnalyticsOverview();
});

final financialMetricsProvider = FutureProvider<FinancialMetrics>((ref) async {
  return await ref.watch(adminRepositoryProvider).getFinancials();
});

final pnlProvider = FutureProvider.family<PnLSummary, String>((ref, month) async {
  return await ref.watch(adminRepositoryProvider).getPnL(month);
});

final liquidityProvider = FutureProvider<LiquidityMetrics>((ref) async {
  return await ref.watch(adminRepositoryProvider).getLiquidity();
});

final platformHealthProvider = FutureProvider<PlatformHealth>((ref) async {
  return await ref.watch(adminRepositoryProvider).getHealth();
});
