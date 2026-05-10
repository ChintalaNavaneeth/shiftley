import 'package:dio/dio.dart';
import '../domain/models/auth_models.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<AuthResponse> sendOtp(SendOtpRequest request) async {
    try {
      final response = await _dio.post(
        'auth/otp/send',
        data: request.toJson(),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> verifyOtp(VerifyOtpRequest request) async {
    try {
      final response = await _dio.post(
        'auth/otp/verify',
        data: request.toJson(),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        'auth/token/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('auth/logout', options: Options(extra: {'no-retry': true}));
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Category>> getTaxonomy() async {
    try {
      final response = await _dio.get('auth/taxonomy');
      final List<dynamic> data = response.data['data'];
      return data.map((e) => Category.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> completeEmployeeOnboarding(FormData data) async {
    try {
      final response = await _dio.post(
        'onboarding/employee',
        data: data,
        options: Options(contentType: 'multipart/form-data'),
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> completeEmployerOnboarding(FormData data) async {
    try {
      final response = await _dio.post(
        'onboarding/employer',
        data: data,
        options: Options(contentType: 'multipart/form-data'),
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
