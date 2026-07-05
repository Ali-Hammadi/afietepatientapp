// lib/core/network/dio_factory.dart
import 'dart:async';
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/core/network/api_endpoints.dart';
import 'package:afiete/core/network/token_storage.dart';
import 'package:afiete/core/reset/nuclear_reset_helper.dart';
import 'package:afiete/core/routes/app_route.dart';
import 'package:afiete/core/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class DioFactory {
  static const String baseUrl =
      'https://seventy-unlined-freefall.ngrok-free.dev/';

  static Completer<bool>? _refreshCompleter;

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (kDebugMode) {
      final log = loggerFor('DioFactory');
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          logPrint: (obj) => log.info('$obj'),
        ),
      );
    }

    // ✅ Language Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final languageCode = SettingsStrings.isArabic ? 'ar' : 'en';
          options.headers['X-Language'] = languageCode;
          if (kDebugMode) {
            print(
                '🌐 [Language Interceptor] Sending X-Language: $languageCode');
          }
          handler.next(options);
        },
      ),
    );

    // ✅ Token + Retry Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getAccessToken();
          if (kDebugMode) {
            print(
                '🔥 [Dio Interceptor] Sending Token for ${options.uri}: Token is ${token != null ? "Present (${token.substring(0, 10)}...)" : "NULL"}');
          }

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (err, handler) async {
          // ✅ 1. فحص Connection Errors أولاً (ngrok instability)
          if (_isConnectionError(err)) {
            final retryCount =
                err.requestOptions.headers['x-retry-count'] as int? ?? 0;
            const maxRetries = 3;

            if (retryCount < maxRetries) {
              final newRetryCount = retryCount + 1;
              if (kDebugMode) {
                print('⚠️ Connection error: ${err.type}');
                print(
                    '🔄 Retry attempt $newRetryCount/$maxRetries for ${err.requestOptions.uri}');
              }

              await Future.delayed(Duration(seconds: newRetryCount));

              final retryOptions = err.requestOptions;
              retryOptions.headers['x-retry-count'] = newRetryCount;

              try {
                final retryResponse = await dio.fetch<dynamic>(retryOptions);
                if (kDebugMode) {
                  print('✅ Retry succeeded on attempt $newRetryCount');
                }
                return handler.resolve(retryResponse);
              } catch (retryError) {
                if (kDebugMode) {
                  print('❌ Retry attempt $newRetryCount failed');
                }

                if (newRetryCount >= maxRetries) {
                  if (kDebugMode) {
                    print('🚫 Max retries reached, returning original error');
                  }
                  return handler.reject(err);
                }

                if (retryError is DioException) {
                  return handler.next(retryError);
                }
                return handler.reject(err);
              }
            }
          }

          // ✅ 2. باقي الـ logic الأصلي (token refresh)
          final statusCode = err.response?.statusCode;
          final data = err.response?.data;

          final missingUser = _isMissingUserResponse(
            statusCode,
            data,
            err.requestOptions.path,
          );

          if (missingUser) {
            await TokenStorage.clearTokens();
            NuclearResetHelper.navigatorKey.currentState
                ?.pushNamedAndRemoveUntil(
              MyRoutes.splashScreen,
              (route) => false,
            );
            return handler.reject(err);
          }

          final isTokenError = _isExpiredTokenResponse(statusCode, data);
          final unauthorized = statusCode == 401 || isTokenError;
          final alreadyRetried =
              err.requestOptions.headers['x-no-retry'] == true;

          // ✅ 3. Token Refresh Logic - محسّن
          if (unauthorized && !alreadyRetried) {
            if (kDebugMode) {
              print('🔑 Token expired, attempting refresh...');
            }

            final refreshed = await _tryRefreshToken(dio);

            if (refreshed) {
              if (kDebugMode) {
                print('✅ Token refreshed successfully');
              }

              final retryOptions = err.requestOptions;
              retryOptions.headers['x-no-retry'] = true;

              final newAccessToken = await TokenStorage.getAccessToken();
              if (newAccessToken != null && newAccessToken.isNotEmpty) {
                retryOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';
              }

              try {
                final retryResponse = await dio.fetch<dynamic>(retryOptions);
                return handler.resolve(retryResponse);
              } catch (e) {
                if (kDebugMode) {
                  print('❌ Retry after refresh failed: $e');
                }
                // ✅ ما نعمل logout، نرجع الـ error الأصلي
                return handler.reject(err);
              }
            } else {
              if (kDebugMode) {
                print('❌ Token refresh failed');
              }
              // ✅ فقط إذا الـ refresh فشل، نعمل logout
              await TokenStorage.clearTokens();
              NuclearResetHelper.navigatorKey.currentState
                  ?.pushNamedAndRemoveUntil(
                MyRoutes.splashScreen,
                (route) => false,
              );
              return handler.reject(err);
            }
          }

          // ✅ 4. إذا كان unauthorized ومحاولة سابقة فشلت
          if (unauthorized && alreadyRetried) {
            await TokenStorage.clearTokens();
            NuclearResetHelper.navigatorKey.currentState
                ?.pushNamedAndRemoveUntil(
              MyRoutes.splashScreen,
              (route) => false,
            );
            return handler.reject(err);
          }

          // ✅ 5. باقي الأخطاء
          final cleanMessage = _mapDioErrorToMessage(err);
          handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              response: err.response,
              type: err.type,
              error: cleanMessage,
              message: cleanMessage,
            ),
          );
        },
      ),
    );

    return dio;
  }

  // ✅ دالة جديدة: فحص Connection Errors
  static bool _isConnectionError(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout) return true;
    if (err.type == DioExceptionType.receiveTimeout) return true;
    if (err.type == DioExceptionType.sendTimeout) return true;

    if (err.type == DioExceptionType.unknown) {
      final errorMessage = err.message?.toLowerCase() ?? '';
      final errorString = err.error?.toString().toLowerCase() ?? '';

      if (errorMessage.contains('connection closed') ||
          errorMessage.contains('failed host lookup') ||
          errorMessage.contains('socket') ||
          errorMessage.contains('network') ||
          errorMessage.contains('connection reset') ||
          errorMessage.contains('connection refused') ||
          errorString.contains('connection closed') ||
          errorString.contains('httpexception') ||
          errorString.contains('socketexception')) {
        return true;
      }
    }

    return false;
  }

  // ✅ تحسين _tryRefreshToken
  static Future<bool> _tryRefreshToken(Dio dio) async {
    // ✅ إذا في عملية refresh جارية، ننتظرها
    if (_refreshCompleter != null) {
      if (kDebugMode) {
        print('⏳ Refresh already in progress, waiting...');
      }
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();

    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        if (kDebugMode) {
          print('❌ No refresh token found');
        }
        _refreshCompleter!.complete(false);
        return false;
      }

      if (kDebugMode) {
        print('🔄 Attempting token refresh...');
        print('🔑 Refresh token: ${refreshToken.substring(0, 10)}...');
      }

      final refreshDio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 20),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      // ✅ محاولة 1: Django SimpleJWT format
      try {
        final response = await refreshDio.post<Map<String, dynamic>>(
          ApiEndpoints.refreshToken,
          data: {"refresh": refreshToken}, // ✅ key الصحيح لـ SimpleJWT
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final refreshedAccessToken = _extractAccessToken(response.data);

          if (refreshedAccessToken != null && refreshedAccessToken.isNotEmpty) {
            final refreshedRefreshToken =
                _extractRefreshToken(response.data) ?? refreshToken;

            await TokenStorage.saveTokens(
              accessToken: refreshedAccessToken,
              refreshToken: refreshedRefreshToken,
            );

            if (kDebugMode) {
              print('✅ Token refreshed successfully (SimpleJWT format)');
            }

            _refreshCompleter!.complete(true);
            return true;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ SimpleJWT format failed: $e');
        }
      }

      // ✅ محاولة 2: Custom format
      try {
        final response = await refreshDio.post<Map<String, dynamic>>(
          ApiEndpoints.refreshToken,
          data: {"refresh_token": refreshToken},
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final refreshedAccessToken = _extractAccessToken(response.data);

          if (refreshedAccessToken != null && refreshedAccessToken.isNotEmpty) {
            final refreshedRefreshToken =
                _extractRefreshToken(response.data) ?? refreshToken;

            await TokenStorage.saveTokens(
              accessToken: refreshedAccessToken,
              refreshToken: refreshedRefreshToken,
            );

            if (kDebugMode) {
              print('✅ Token refreshed successfully (Custom format)');
            }

            _refreshCompleter!.complete(true);
            return true;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Custom format failed: $e');
        }
      }

      if (kDebugMode) {
        print('❌ Token refresh failed - no valid response');
      }
      _refreshCompleter!.complete(false);
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Token refresh exception: $e');
      }
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  static String _mapDioErrorToMessage(DioException err) {
    if (_isConnectionError(err)) {
      return 'Connection error. Please check your internet connection and try again.';
    }

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return 'The connection timed out. Please try again.';
    }

    if (err.type == DioExceptionType.cancel) {
      return 'Request was cancelled.';
    }

    final statusCode = err.response?.statusCode;
    final data = err.response?.data;
    final responseMessage = _toUserFriendlyMessage(
      _extractResponseMessage(data),
    );

    if (_isMissingUserResponse(statusCode, data, err.requestOptions.path)) {
      return 'No account was found for this email.';
    }

    if (_isInvalidOtpResponse(statusCode, data)) {
      return 'The verification code is invalid or expired.';
    }

    if (_isExpiredTokenResponse(statusCode, data)) {
      return 'Your session has expired. Please sign in again.';
    }

    if (statusCode == 400) {
      return responseMessage ?? 'Invalid request. Please check your input.';
    }
    if (statusCode == 401) {
      return responseMessage ?? 'Authentication failed. Please sign in again.';
    }
    if (statusCode == 403) {
      return responseMessage ?? 'Access is forbidden.';
    }
    if (statusCode == 404) {
      return responseMessage ?? 'Resource not found.';
    }
    if (statusCode == 409) {
      return responseMessage ?? 'Resource already exists.';
    }
    if (statusCode == 422) {
      return responseMessage ?? 'Validation failed.';
    }
    if (statusCode == 429) {
      return responseMessage ?? 'Too many requests. Please try again later.';
    }
    if (statusCode != null && statusCode >= 500) {
      return responseMessage ?? 'Server error. Please try again later.';
    }

    return responseMessage ?? 'Unexpected error occurred.';
  }

  static String? _extractResponseMessage(dynamic data) {
    if (data == null) return null;

    if (data is String) {
      final text = data.trim();
      if (text.isEmpty) return null;
      return _isGenericBackendMessage(text) ? null : text;
    }

    if (data is List) {
      for (final item in data) {
        final found = _extractResponseMessage(item);
        if (found != null && found.isNotEmpty) return found;
      }
      return null;
    }

    if (data is Map<String, dynamic>) {
      final directMessage = data['message']?.toString();
      if (directMessage != null &&
          directMessage.isNotEmpty &&
          !_isGenericBackendMessage(directMessage)) {
        return directMessage;
      }

      final detailMessage = data['detail']?.toString();
      if (detailMessage != null &&
          detailMessage.isNotEmpty &&
          !_isGenericBackendMessage(detailMessage)) {
        return detailMessage;
      }

      const reservedKeys = {
        'message',
        'detail',
        'error',
        'errors',
        'status',
        'code',
      };

      for (final entry in data.entries) {
        if (reservedKeys.contains(entry.key.toLowerCase())) continue;
        final found = _extractResponseMessage(entry.value);
        if (found != null && found.isNotEmpty) return found;
      }
    }

    return null;
  }

  static bool _isMissingUserResponse(
    int? statusCode,
    dynamic data,
    String requestPath,
  ) {
    if (statusCode != 404) return false;

    final normalizedPath = requestPath.toLowerCase();
    final isAccountRoute = normalizedPath.contains('/api/users/') ||
        normalizedPath.contains('/api/patients/') ||
        normalizedPath.contains('/api/auth/') ||
        normalizedPath.endsWith('/profile') ||
        normalizedPath.endsWith('/profile/');

    if (!isAccountRoute) return false;

    final message = _extractResponseMessage(data)?.toLowerCase() ?? '';
    return message.contains('no user matches the given query') ||
        message.contains('no user') ||
        message.contains('not found') ||
        message.contains('deleted');
  }

  static bool _isInvalidOtpResponse(int? statusCode, dynamic data) {
    if (statusCode != 400) return false;

    final message = _extractResponseMessage(data)?.toLowerCase() ?? '';
    return message.contains('invalid otp') ||
        message.contains('invalid code') ||
        message.contains('expired');
  }

  static bool _isExpiredTokenResponse(int? statusCode, dynamic data) {
    if (statusCode != 401 && statusCode != 403) return false;

    final message = _extractResponseMessage(data)?.toLowerCase() ?? '';
    if (message.contains('token_not_valid') ||
        (message.contains('token') && message.contains('expired'))) {
      return true;
    }

    if (data is Map<String, dynamic>) {
      final code = data['code']?.toString().toLowerCase() ?? '';
      if (code == 'token_not_valid') return true;

      final messages = data['messages'];
      if (messages is List) {
        for (final item in messages) {
          final text = item is Map
              ? '${item['message'] ?? ''} ${item['detail'] ?? ''}'.toLowerCase()
              : item.toString().toLowerCase();
          if (text.contains('token') && text.contains('expired')) {
            return true;
          }
        }
      }
    }

    return false;
  }

  static bool _isGenericBackendMessage(String message) {
    final normalized = message.trim().toLowerCase();
    return normalized == 'invalid request. please check your input.' ||
        normalized == 'invalid request' ||
        normalized == 'bad request';
  }

  static String? _toUserFriendlyMessage(String? message) {
    if (message == null || message.trim().isEmpty) return null;

    final normalized = message.trim().toLowerCase();

    if (normalized.contains('inactive') ||
        normalized.contains('disabled') ||
        normalized.contains('blocked')) {
      return 'This account is inactive. Please contact support.';
    }

    if (normalized.contains('already verified')) {
      return 'Your account is already verified.';
    }

    if (normalized.contains('does not exist') ||
        normalized.contains('not found')) {
      return 'No account was found for this data.';
    }

    if (normalized.contains('already exists')) {
      return 'This email is already registered.';
    }

    if (normalized.contains('invalid otp') ||
        normalized.contains('invalid code')) {
      return 'The verification code is incorrect.';
    }

    if (normalized.contains('password') && normalized.contains('incorrect')) {
      return 'The current password is incorrect.';
    }

    if (_isGenericBackendMessage(normalized)) {
      return 'Your request could not be processed.';
    }

    return message.trim();
  }

  static String? _extractAccessToken(dynamic data) {
    if (data is Map<String, dynamic>) {
      final candidates = ['access', 'access_token', 'accessToken'];

      for (final key in candidates) {
        final v = data[key];
        if (v != null && v.toString().isNotEmpty) return v.toString();
      }

      final nested = data['data'];
      if (nested is Map<String, dynamic>) {
        for (final key in candidates) {
          final v = nested[key];
          if (v != null && v.toString().isNotEmpty) return v.toString();
        }
      }

      final tokens = data['tokens'];
      if (tokens is Map<String, dynamic>) {
        for (final key in candidates) {
          final v = tokens[key];
          if (v != null && v.toString().isNotEmpty) return v.toString();
        }
      }
    }

    return null;
  }

  static String? _extractRefreshToken(dynamic data) {
    if (data is Map<String, dynamic>) {
      final candidates = ['refresh', 'refresh_token', 'refreshToken'];

      for (final key in candidates) {
        final v = data[key];
        if (v != null && v.toString().isNotEmpty) return v.toString();
      }

      final nested = data['data'];
      if (nested is Map<String, dynamic>) {
        for (final key in candidates) {
          final v = nested[key];
          if (v != null && v.toString().isNotEmpty) return v.toString();
        }
      }

      final tokens = data['tokens'];
      if (tokens is Map<String, dynamic>) {
        for (final key in candidates) {
          final v = tokens[key];
          if (v != null && v.toString().isNotEmpty) return v.toString();
        }
      }
    }

    return null;
  }
}
