import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shiftley_frontend/features/verifier/domain/models/verifier_models.dart';

class VerifierRepository {
  final Dio _dio;

  VerifierRepository(this._dio);

  Future<List<QueueItem>> getQueue({String? type}) async {
    try {
      final response = await _dio.get('verifier/queue', queryParameters: type != null ? {'type': type} : null);
      final List? data = response.data['data'];
      if (data == null) return [];
      return data.map((item) => QueueItem.fromJson(item)).toList();
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
      final response = await _dio.get('verifier/profile');
      return VerifierProfile.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
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
}
