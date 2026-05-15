import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftley_frontend/core/network/api_client.dart';
import 'package:shiftley_frontend/core/network/api_providers.dart';
import 'package:shiftley_frontend/features/employee/domain/models/employee_models.dart';
import 'package:shiftley_frontend/shared/domain/models/gig_models.dart';

class EmployeeRepository {
  final ApiClient _apiClient;

  EmployeeRepository(this._apiClient);

  Future<EmployeeDashboardData> getDashboardData() async {
    final response = await _apiClient.dio.get('/employees/me');
    return EmployeeDashboardData.fromJson(response.data['data']);
  }

  Future<List<Gig>> getMySchedule() async {
    final response = await _apiClient.dio.get('/employees/me/schedule');
    final List<dynamic> data = response.data['data'];
    // In the backend, it returns List<GigApplication>, but we often want the Gigs
    return data.map((json) => Gig.fromJson(json['Gig'])).toList();
  }

  Future<void> updatePayoutMethods(Map<String, dynamic> payoutData) async {
    await _apiClient.dio.put('/employees/me/payout-methods', data: payoutData);
  }

  Future<Map<String, dynamic>> payPenalty() async {
    final response = await _apiClient.dio.post('/employees/me/pay-penalty');
    return response.data['data'];
  }
}

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EmployeeRepository(apiClient);
});

final employeeDashboardProvider = FutureProvider<EmployeeDashboardData>((ref) async {
  return ref.watch(employeeRepositoryProvider).getDashboardData();
});

final employeeScheduleProvider = FutureProvider<List<Gig>>((ref) async {
  return ref.watch(employeeRepositoryProvider).getMySchedule();
});
