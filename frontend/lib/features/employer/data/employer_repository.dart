import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftley_frontend/core/network/api_client.dart';
import 'package:shiftley_frontend/core/network/api_providers.dart';
import 'package:shiftley_frontend/features/employer/domain/models/employer_models.dart';
import 'package:shiftley_frontend/shared/domain/models/gig_models.dart';

class EmployerRepository {
  final ApiClient _apiClient;

  EmployerRepository(this._apiClient);

  Future<EmployerDashboardData> getDashboardData() async {
    final response = await _apiClient.dio.get('/employers/me');
    return EmployerDashboardData.fromJson(response.data['data']);
  }

  Future<List<Gig>> getMyGigs({String? status}) async {
    final response = await _apiClient.dio.get(
      '/employers/me/gigs',
      queryParameters: status != null ? {'status': status} : null,
    );
    final List<dynamic> data = response.data['data'];
    return data.map((json) => Gig.fromJson(json)).toList();
  }

  Future<void> purchaseSubscription(String planId) async {
    await _apiClient.dio.post(
      '/employers/me/subscription',
      data: {'plan_id': planId},
    );
  }
}

final employerRepositoryProvider = Provider<EmployerRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EmployerRepository(apiClient);
});

final employerDashboardProvider = FutureProvider<EmployerDashboardData>((ref) async {
  return ref.watch(employerRepositoryProvider).getDashboardData();
});

final employerGigsProvider = FutureProvider.family<List<Gig>, String?>((ref, status) async {
  return ref.watch(employerRepositoryProvider).getMyGigs(status: status);
});
