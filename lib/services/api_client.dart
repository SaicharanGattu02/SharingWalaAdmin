import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/api_config/admin_endpoints.dart';
import 'admin_auth_service.dart';

class ApiClient {
  static final Dio _dio = _createDio();

  static Dio get dio => _dio;

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AdminEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AdminAuthService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // If error is from the refresh endpoint itself, clear auth and forward
          if (error.requestOptions.path.contains('/auth/refresh')) {
            await AdminAuthService.clearAuth();
            return handler.next(error);
          }

          if (error.response?.statusCode == 401) {
            final refreshToken = await AdminAuthService.getRefreshToken();
            if (refreshToken == null || refreshToken.isEmpty) {
              await AdminAuthService.clearAuth();
              return handler.next(error);
            }

            try {
              // Attempt to refresh the access token silently
              final refreshResponse = await dio.post(
                AdminEndpoints.refresh,
                data: {'refreshToken': refreshToken},
              );

              final respMap = refreshResponse.data is Map<String, dynamic>
                  ? refreshResponse.data as Map<String, dynamic>
                  : <String, dynamic>{};
              final dataMap = respMap['data'] is Map<String, dynamic>
                  ? respMap['data'] as Map<String, dynamic>
                  : respMap;

              final isSuccess = refreshResponse.statusCode == 200 &&
                  (respMap['success'] == true || respMap['statusCode'] == 200);

              if (isSuccess &&
                  (dataMap['accessToken'] != null ||
                      dataMap['token'] != null ||
                      respMap['accessToken'] != null)) {
                final newAccessToken = (dataMap['accessToken'] ??
                        dataMap['token'] ??
                        respMap['accessToken'] ??
                        respMap['token'])
                    .toString();
                final newRefreshToken =
                    (dataMap['refreshToken'] ?? respMap['refreshToken'])?.toString();

                await AdminAuthService.updateTokens(newAccessToken, newRefreshToken);

                // Retry original request with the fresh access token
                final options = error.requestOptions;
                options.headers['Authorization'] = 'Bearer $newAccessToken';
                final retryResponse = await dio.fetch(options);
                return handler.resolve(retryResponse);
              }
            } catch (_) {
              await AdminAuthService.clearAuth();
              return handler.next(error);
            }
          }

          return handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: false,
          responseHeader: false,
        ),
      );
    }

    return dio;
  }

  static String formatError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data is Map<String, dynamic>) {
        final data = error.response!.data as Map<String, dynamic>;
        if (data['message'] != null && data['message'].toString().isNotEmpty) {
          return data['message'].toString();
        }
      }
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please check your internet connection.';
        case DioExceptionType.connectionError:
          return 'Unable to reach the server. Please check your network connection or verify server status.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            return 'Invalid credentials or verification code.';
          } else if (statusCode == 403) {
            return 'Access denied. Super administrator privileges required.';
          } else if (statusCode == 404) {
            return 'Requested resource not found.';
          } else if (statusCode != null && statusCode >= 500) {
            return 'Server temporary error ($statusCode). Please try again shortly.';
          }
          return 'Request failed with status code $statusCode.';
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        default:
          return 'Network request failed. Please check your connection.';
      }
    }
    return error.toString().replaceAll('Exception:', '').trim();
  }
}
