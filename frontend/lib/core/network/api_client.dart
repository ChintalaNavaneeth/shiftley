import 'package:dio/dio.dart';
import 'token_storage.dart';

class ApiClient {
  late final Dio dio;
  final TokenStorage _tokenStorage = TokenStorage();
  
  // Replace with your actual backend URL
  static const String baseUrl = 'http://localhost:8080/api/v1';

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshToken = await _tokenStorage.getRefreshToken();
          if (refreshToken != null) {
            try {
              // Attempt to refresh the token
              final response = await dio.post('/auth/token/refresh', data: {
                'refresh_token': refreshToken,
              });

              if (response.statusCode == 200) {
                final newAccessToken = response.data['data']['access_token'];
                final newRefreshToken = response.data['data']['refresh_token'];

                await _tokenStorage.saveTokens(
                  accessToken: newAccessToken,
                  refreshToken: newRefreshToken,
                );

                // Retry the original request with the new access token
                error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                final opts = Options(
                  method: error.requestOptions.method,
                  headers: error.requestOptions.headers,
                );
                
                final retryResponse = await dio.request(
                  error.requestOptions.path,
                  options: opts,
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                );
                
                return handler.resolve(retryResponse);
              }
            } catch (e) {
              // If refresh fails, clear tokens and redirect to login (via event or state)
              await _tokenStorage.clearTokens();
            }
          }
        }
        return handler.next(error);
      },
    ));
  }
}
