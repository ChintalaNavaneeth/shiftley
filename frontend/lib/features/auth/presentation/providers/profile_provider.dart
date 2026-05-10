import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftley_frontend/features/auth/data/auth_repository_provider.dart';

final userProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(authRepositoryProvider).getMe();
});
