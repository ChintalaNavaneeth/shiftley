import 'package:dio/dio.dart';
import 'token_storage.dart';

class ApiClient {
  late final Dio dio;
  final TokenStorage _tokenStorage = TokenStorage();
  
  // Replace with your actual backend URL
  // Use your machine's local IP for reliable emulator connection
  static const String baseUrl = 'http://192.168.1.6:8080/api/v1';

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ));

    dio.interceptors.add(LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      error: true,
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
        // Prevent infinite loop: Don't refresh if the request is marked as no-retry
        // or if it's already a refresh/logout request
        final bool noRetry = error.requestOptions.extra['no-retry'] == true;
        final bool isAuthPath = error.requestOptions.path.contains('/auth/token/refresh') || 
                               error.requestOptions.path.contains('/auth/logout');
        
        if (error.response?.statusCode == 401 && !noRetry && !isAuthPath) {
          final refreshToken = await _tokenStorage.getRefreshToken();
          if (refreshToken != null) {
            try {
              // Use a separate options object with no-retry to prevent recursion
              final response = await dio.post(
                '/auth/token/refresh',
                data: {'refresh_token': refreshToken},
                options: Options(extra: {'no-retry': true}),
              );

              if (response.statusCode == 200) {
                final newAccessToken = response.data['data']['access_token'];
                final newRefreshToken = response.data['data']['refresh_token'];

                await _tokenStorage.saveTokens(
                  accessToken: newAccessToken,
                  refreshToken: newRefreshToken,
                );

                // Retry the original request with the new access token
                error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                
                final extra = Map<String, dynamic>.from(error.requestOptions.extra);
                extra['no-retry'] = true;
                
                final opts = Options(
                  method: error.requestOptions.method,
                  headers: error.requestOptions.headers,
                  extra: extra,
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
