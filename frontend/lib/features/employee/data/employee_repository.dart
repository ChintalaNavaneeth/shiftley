import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftley_frontend/core/network/api_client.dart';
import 'package:shiftley_frontend/core/network/api_providers.dart';
import 'package:shiftley_frontend/features/employee/domain/models/employee_models.dart';
import 'package:shiftley_frontend/shared/domain/models/gig_models.dart';
import 'package:geolocator/geolocator.dart';

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

  Future<List<Gig>> searchGigs({String? query, double? lat, double? lng, double? radiusKm}) async {
    // If no location provided, we don't search (as per user request)
    if (lat == null || lng == null) return [];

    final response = await _apiClient.dio.get('/gigs/search', queryParameters: {
      if (query != null && query.isNotEmpty) 'query': query,
      'lat': lat,
      'lng': lng,
      'radius_km': radiusKm ?? 50,
    });
    
    final dynamic responseData = response.data['data'];
    if (responseData == null) return [];
    
    final List<dynamic> data = responseData;
    return data.map((json) => Gig.fromJson(json)).toList();
  }

  Future<void> applyForGig(String gigId) async {
    await _apiClient.dio.post('/gigs/$gigId/apply');
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

final gigSearchQueryProvider = StateProvider<String>((ref) => '');
final gigSearchRadiusProvider = StateProvider<double>((ref) => 50.0);

final userLocationProvider = FutureProvider<Position?>((ref) async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw 'Location services are disabled.';
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw 'Location permissions are denied';
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    throw 'Location permissions are permanently denied';
  }

  return await Geolocator.getCurrentPosition();
});

final exploreGigsProvider = FutureProvider<List<Gig>>((ref) async {
  final query = ref.watch(gigSearchQueryProvider);
  final radius = ref.watch(gigSearchRadiusProvider);
  final locationAsync = ref.watch(userLocationProvider);
  
  final location = locationAsync.value;
  
  return ref.watch(employeeRepositoryProvider).searchGigs(
    query: query,
    radiusKm: radius,
    lat: location?.latitude,
    lng: location?.longitude,
  );
});
