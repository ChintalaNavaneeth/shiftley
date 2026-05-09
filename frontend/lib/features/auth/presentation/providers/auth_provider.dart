import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shiftley_frontend/core/network/api_providers.dart';
import '../../data/auth_repository_provider.dart';
import '../../domain/models/auth_models.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  FutureOr<AuthData?> build() async {
    final storage = ref.read(tokenStorageProvider);
    final token = await storage.getAccessToken();
    if (token != null) {
      // For now, we assume we are authenticated if we have a token
      // In a real app, we might fetch the user profile here
      return null; // Placeholder
    }
    return null;
  }

  Future<AuthResponse> sendOtp(String identifier, String type, String role) async {
    final repo = ref.read(authRepositoryProvider);
    return await repo.sendOtp(SendOtpRequest(
      identifier: identifier,
      type: type,
      role: role,
    ));
  }

  Future<AuthResponse> verifyOtp(String identifier, String type, String code) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final response = await repo.verifyOtp(VerifyOtpRequest(
        identifier: identifier,
        type: type,
        code: code,
      ));

      if (response.data != null && response.data is Map<String, dynamic>) {
        final data = AuthData.fromJson(response.data as Map<String, dynamic>);
        final storage = ref.read(tokenStorageProvider);
        
        if (data.isNewUser) {
          await storage.saveTokens(
            accessToken: data.registrationToken!,
            refreshToken: data.refreshToken!,
          );
        } else {
          await storage.saveTokens(
            accessToken: data.accessToken!,
            refreshToken: data.refreshToken!,
          );
        }
        state = AsyncValue.data(data);
      } else {
        state = AsyncValue.error(response.message ?? 'Unknown error', StackTrace.current);
      }
      return response;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.logout();
    } catch (e) {
      // Ignore logout errors (like 401) because if the session is already 
      // invalid on the server, we just need to clear it locally anyway.
      debugPrint('Logout request failed (expected if session revoked): $e');
    } finally {
      final storage = ref.read(tokenStorageProvider);
      await storage.clearTokens();
      state = const AsyncValue.data(null);
    }
  }
}
