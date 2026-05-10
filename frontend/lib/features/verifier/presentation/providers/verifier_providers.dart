import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftley_frontend/features/employer/domain/models/employer_models.dart';
import 'package:shiftley_frontend/features/verifier/data/verifier_repository_provider.dart';
import 'package:shiftley_frontend/features/verifier/domain/models/verifier_models.dart';

final verifierQueueListProvider = FutureProvider.family<List<QueueItem>, ({String? type, String? status})>((ref, args) {
  return ref.watch(verifierRepositoryProvider).getQueue(type: args.type, status: args.status);
});

final verifierHistoryListProvider = FutureProvider.family<List<VerificationAudit>, ({String? from, String? to, String? query})>((ref, args) {
  return ref.watch(verifierRepositoryProvider).getHistory(from: args.from, to: args.to, query: args.query);
});

final verifierProfileProvider = FutureProvider<VerifierProfile>((ref) {
  return ref.watch(verifierRepositoryProvider).getProfile();
});

final employerDetailsProvider = FutureProvider.family<EmployerProfile, String>((ref, id) {
  return ref.watch(verifierRepositoryProvider).getEmployerDetails(id);
});
