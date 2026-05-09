import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shiftley_frontend/features/verifier/data/verifier_repository_provider.dart';
import 'package:shiftley_frontend/features/verifier/domain/models/verifier_models.dart';

part 'verifier_providers.g.dart';

@riverpod
Future<List<QueueItem>> verifierQueue(VerifierQueueRef ref, {String? type}) {
  return ref.watch(verifierRepositoryProvider).getQueue(type: type);
}

@riverpod
Future<List<VerificationAudit>> verifierHistory(VerifierHistoryRef ref) {
  return ref.watch(verifierRepositoryProvider).getHistory();
}

@riverpod
Future<VerifierProfile> verifierProfile(VerifierProfileRef ref) {
  return ref.watch(verifierRepositoryProvider).getProfile();
}
