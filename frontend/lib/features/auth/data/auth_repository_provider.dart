import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftley_frontend/core/network/api_providers.dart';
import 'auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthRepository(dio, prefs);
});

final taxonomyProvider = FutureProvider((ref) {
  return ref.watch(authRepositoryProvider).getTaxonomy();
});
