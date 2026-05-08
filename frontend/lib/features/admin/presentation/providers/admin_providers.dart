import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/admin_repository.dart';
import '../../domain/admin_models.dart';

part 'admin_providers.g.dart';

@riverpod
class AdminTaxonomy extends _$AdminTaxonomy {
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

@riverpod
class ManagementUsers extends _$ManagementUsers {
  @override
  FutureOr<List<ManagementUser>> build() async {
    return await ref.watch(adminRepositoryProvider).getManagementUsers();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(adminRepositoryProvider).getManagementUsers());
  }

  Future<void> inviteStaff(String fullName, String email, String phone, String role) async {
    await ref.read(adminRepositoryProvider).createManagementUser(fullName, email, phone, role);
    await refresh();
  }

  Future<void> updateStatus(String id, String status) async {
    await ref.read(adminRepositoryProvider).updateUserStatus(id, status);
    await refresh();
  }
}

@riverpod
class PlatformConfigNotifier extends _$PlatformConfigNotifier {
  @override
  FutureOr<PlatformConfig> build() async {
    return await ref.watch(adminRepositoryProvider).getPlatformConfig();
  }

  Future<void> updateFees(double feePercentage) async {
    await ref.read(adminRepositoryProvider).updatePlatformConfig(feePercentage);
    state = await AsyncValue.guard(() => ref.read(adminRepositoryProvider).getPlatformConfig());
  }
}

@riverpod
class PendingDisputes extends _$PendingDisputes {
  @override
  FutureOr<List<Dispute>> build() async {
    return await ref.watch(adminRepositoryProvider).getPendingDisputes();
  }

  Future<void> resolve(String id, String resolution, String notes) async {
    await ref.read(adminRepositoryProvider).resolveDispute(id, resolution, notes);
    state = await AsyncValue.guard(() => ref.read(adminRepositoryProvider).getPendingDisputes());
  }
}

@riverpod
Future<AnalyticsOverview> analyticsOverview(AnalyticsOverviewRef ref) async {
  return await ref.watch(adminRepositoryProvider).getAnalyticsOverview();
}

@riverpod
Future<FinancialMetrics> financialMetrics(FinancialMetricsRef ref) async {
  return await ref.watch(adminRepositoryProvider).getFinancials();
}
