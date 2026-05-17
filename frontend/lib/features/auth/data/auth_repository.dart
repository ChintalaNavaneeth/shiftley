import 'package:flutter/foundation.dart' hide Category;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/auth_models.dart';

class AuthRepository {
  final Dio _dio;
  final SharedPreferences _prefs;

  AuthRepository(this._dio, this._prefs);

  Future<AuthResponse> sendOtp(SendOtpRequest request) async {
    try {
      String path = 'auth/otp/send';
      if (request.role == 'SUPER_ADMIN' || request.role == 'ADMIN') {
        path = 'auth/admin/otp/send';
      } else if (request.role == 'EMPLOYER') {
        path = 'auth/employer/otp/send';
      } else if (request.role == 'VERIFIER') {
        path = 'auth/verifier/otp/send';
      }

      final response = await _dio.post(
        path,
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
      String path = 'auth/otp/verify';
      if (request.role == 'SUPER_ADMIN' || request.role == 'ADMIN') {
        path = 'auth/admin/otp/verify';
      } else if (request.role == 'EMPLOYER') {
        path = 'auth/employer/otp/verify';
      } else if (request.role == 'VERIFIER') {
        path = 'auth/verifier/otp/verify';
      }

      final response = await _dio.post(
        path,
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
      debugPrint('AuthRepository: Attempting API logout at auth/logout');
      await _dio.post('auth/logout', options: Options(extra: {'no-retry': true}));
      debugPrint('AuthRepository: API logout successful');
    } catch (e) {
      debugPrint('AuthRepository: API logout failed (continuing to clear local state): $e');
    } finally {
      // Always clear local cache on logout regardless of API success
      await _prefs.clear(); 
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      // 1. Fetch API (Disabled cache to ensure fresh data for skills/profile)
      debugPrint('AuthRepository: Fetching profile from /auth/me');
      final response = await _dio.get('auth/me');
      
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data['data'];
      if (data == null || data is! Map<String, dynamic>) {
        debugPrint('AuthRepository: Invalid data structure: ${response.data}');
        throw Exception('Invalid data structure from server');
      }
      
      return data;
    } catch (e) {
      debugPrint('AuthRepository: getMe CRITICAL ERROR: $e');
      if (e is DioException) {
        debugPrint('Dio Error Detail: ${e.response?.statusCode} - ${e.response?.data}');
      }
      rethrow;
    }
  }

  Future<List<Category>> getTaxonomy() async {
    try {
      final response = await _dio.get('taxonomy');
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

  Future<void> deleteSkill(String skillId) async {
    try {
      await _dio.delete('employees/me/skills/$skillId');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addSkill(String skillId) async {
    try {
      await _dio.post('employees/me/skills', data: {'skill_id': skillId});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCertification(String certId) async {
    try {
      await _dio.delete('employees/me/certifications/$certId');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addCertification(Map<String, dynamic> certData) async {
    try {
      await _dio.post('employees/me/certifications', data: certData);
    } catch (e) {
      rethrow;
    }
  }
}
