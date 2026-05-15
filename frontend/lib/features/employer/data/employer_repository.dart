import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftley_frontend/core/network/api_client.dart';
import 'package:shiftley_frontend/core/network/api_providers.dart';
import 'package:shiftley_frontend/core/network/token_storage.dart';
import 'package:shiftley_frontend/features/employer/domain/models/employer_models.dart';
import 'package:shiftley_frontend/features/employer/domain/models/taxonomy_models.dart';
import 'package:shiftley_frontend/shared/domain/models/gig_models.dart';

class EmployerRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage = TokenStorage();

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

  Future<Gig> postGig(Map<String, dynamic> gigData) async {
    final response = await _apiClient.dio.post('/gigs', data: gigData);
    return Gig.fromJson(response.data['data']);
  }

  Future<Map<String, dynamic>> postGigRaw(Map<String, dynamic> gigData, String idempotencyKey) async {
    final response = await _apiClient.dio.post(
      '/gigs',
      data: gigData,
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> confirmGigPayment(String gigId) async {
    final response = await _apiClient.dio.post('/gigs/$gigId/confirm-payment');
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<List<TaxonomyCategory>> getTaxonomy() async {
    final response = await _apiClient.dio.get('/taxonomy');
    final List<dynamic> data = response.data['data'];
    return data.map((json) => TaxonomyCategory.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<GigApplication>> getGigApplications(String gigId) async {
    final response = await _apiClient.dio.get('/gigs/$gigId/applications');
    final List<dynamic> data = response.data['data'];
    return data.map((json) => GigApplication.fromJson(json)).toList();
  }

  Future<void> updateApplicationStatus(String applicationId, String status) async {
    await _apiClient.dio.patch(
      '/applications/$applicationId/status',
      data: {'status': status},
    );
  }

  Future<void> cancelGig(String gigId, String reason) async {
    await _apiClient.dio.post(
      '/gigs/$gigId/cancel',
      data: {'reason': reason},
    );
  }

  Future<void> requestCancelOTP(String gigId) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.dio.post(
      '/gigs/$gigId/cancel/otp',
      options: Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      ),
    );
  }

  Future<void> verifyCancelAndConfirm(String gigId, String code, String reason) async {
    final token = await _tokenStorage.getAccessToken();
    
    await _apiClient.dio.post(
      '/gigs/$gigId/cancel/verify',
      data: {
        'code': code,
        'reason': reason,
      },
      options: Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      ),
    );
  }

  Future<void> markAttendance(String gigId, String employeeId, String status) async {
    final endpoint = status == 'PRESENT' ? 'mark-arrived' : 'complete';
    await _apiClient.dio.post('/gigs/$gigId/employees/$employeeId/$endpoint');
  }

  Future<Map<String, dynamic>> getEmployeeProfile(String employeeId) async {
    final response = await _apiClient.dio.get('/employers/profiles/employees/$employeeId');
    return response.data['data'];
  }

  Future<String> getAttendanceQR(String gigId) async {
    final response = await _apiClient.dio.get('/gigs/$gigId/attendance-qr');
    return response.data['data']['qr_code'];
  }

  Future<void> purchaseSubscription(String planId, String paymentId) async {
    await _apiClient.dio.post(
      '/employers/me/subscription',
      data: {
        'plan_id': planId,
        'payment_id': paymentId,
      },
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

final gigApplicationsProvider = FutureProvider.family<List<GigApplication>, String>((ref, gigId) async {
  return ref.watch(employerRepositoryProvider).getGigApplications(gigId);
});

final taxonomyProvider = FutureProvider<List<TaxonomyCategory>>((ref) async {
  return ref.watch(employerRepositoryProvider).getTaxonomy();
});
