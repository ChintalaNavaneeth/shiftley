import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftley_frontend/core/network/api_providers.dart';
import 'verifier_repository.dart';

final verifierRepositoryProvider = Provider<VerifierRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return VerifierRepository(dio);
});
