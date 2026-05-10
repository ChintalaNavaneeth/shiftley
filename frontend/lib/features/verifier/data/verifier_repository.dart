import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiftley_frontend/features/employer/domain/models/employer_models.dart';
import 'package:shiftley_frontend/features/verifier/domain/models/verifier_models.dart';

class VerifierRepository {
  final Dio _dio;
  final SharedPreferences _prefs;
  static const _profileKey = 'cached_verifier_profile';

  VerifierRepository(this._dio, this._prefs);

  Future<List<QueueItem>> getQueue({String? type, String? status}) async {
    try {
      final Map<String, dynamic> params = {};
      if (type != null) params['type'] = type;
      if (status != null) params['status'] = status;
      
      final response = await _dio.get('verifier/queue', queryParameters: params);
      final List? data = response.data['data'];
      if (data == null) return [];
      return data.map((item) => QueueItem.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<EmployerProfile> getEmployerDetails(String id) async {
    try {
      final response = await _dio.get('verifier/employers/$id');
      return EmployerProfile.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<VerificationAudit>> getHistory() async {
    try {
      final response = await _dio.get('verifier/history');
      final List? data = response.data['data'];
      if (data == null) return [];
      return data.map((item) => VerificationAudit.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<VerifierProfile> getProfile() async {
    try {
      // 1. Try to load from cache
      final cachedJson = _prefs.getString(_profileKey);
      if (cachedJson != null) {
        return VerifierProfile.fromJson(jsonDecode(cachedJson));
      }

      // 2. Fetch from API if cache missing
      final response = await _dio.get('verifier/profile');
      final profile = VerifierProfile.fromJson(response.data['data']);
      
      // 3. Store in cache
      await _prefs.setString(_profileKey, jsonEncode(profile.toJson()));
      
      return profile;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearCache() async {
    await _prefs.remove(_profileKey);
  }

  Future<void> completeOnboarding({
    required XFile profileImage,
    required String aadharPath,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final formData = FormData.fromMap({
        'profile_image': await MultipartFile.fromFile(profileImage.path),
        'aadhar_pdf': await MultipartFile.fromFile(aadharPath),
        'latitude': latitude,
        'longitude': longitude,
      });

      await _dio.post(
        'onboarding/verifier',
        data: formData,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyEmployer({
    required String employerId,
    required XFile selfie,
    required List<XFile> businessPhotos,
    required double lat,
    required double lng,
    String? notes,
    required bool isApproved,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'status': isApproved ? 'APPROVED' : 'REJECTED',
        'notes': notes ?? (isApproved ? 'Verified successfully' : 'Rejected by auditor'),
        'verified_location': '{"lat": $lat, "lng": $lng}',
        'verifier_selfie': await MultipartFile.fromFile(selfie.path),
      };

      for (int i = 0; i < businessPhotos.length; i++) {
        data['location_photo_${i + 1}'] = await MultipartFile.fromFile(businessPhotos[i].path);
      }

      final formData = FormData.fromMap(data);

      await _dio.post(
        'verifier/employers/$employerId/verify',
        data: formData,
      );
    } catch (e) {
      rethrow;
    }
  }
}
