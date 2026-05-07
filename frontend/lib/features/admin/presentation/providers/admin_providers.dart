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
