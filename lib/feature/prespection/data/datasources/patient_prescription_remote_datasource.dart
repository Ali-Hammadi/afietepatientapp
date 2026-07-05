// lib/feature/prespection/data/datasources/patient_prescription_remote_datasource.dart
import 'package:afiete/core/network/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/prescription_model.dart';

class PatientPrescriptionRemoteDataSource {
  final Dio dio;
  final String baseUrl;
  final Future<String?> Function() getToken;

  PatientPrescriptionRemoteDataSource({
    required this.dio,
    required this.baseUrl,
    required this.getToken,
  });

  Future<Options> _getOptions() async {
    final token = await getToken();
    return Options(
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      responseType: ResponseType.json,
    );
  }

  Future<List<PrescriptionModel>> getPrescriptions() async {
    try {
      final options = await _getOptions();
      final response = await dio.get(
        ApiEndpoints.prescription,
        options: options,
      );

      final List<dynamic> data = response.data;
      return data
          .map((json) =>
              PrescriptionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to load prescriptions');
    } catch (e) {
      throw Exception('Failed to load prescriptions: $e');
    }
  }

  Future<PrescriptionModel> getPrescriptionDetail(int id) async {
    try {
      final options = await _getOptions();
      final response = await dio.get(
        ApiEndpoints.getPrescription(id),
        options: options,
      );

      return PrescriptionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to load prescription detail');
    } catch (e) {
      throw Exception('Failed to load prescription detail: $e');
    }
  }

// ✅ تنزيل HTML للوصفة
  Future<String> downloadPrescriptionHtml(int id) async {
    try {
      final token = await getToken();

      // ✅ إصلاح الـ URL - ما نضيف print/ مرتين
      final url = '${ApiEndpoints.getPrescription(id)}print/';

      if (kDebugMode) {
        print('📄 Downloading prescription HTML from: $url');
      }

      final response = await dio.get<String>(
        url,
        options: Options(
          headers: {
            'Accept': 'text/html',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
          responseType: ResponseType.plain, // ✅ مهم جداً!
        ),
      );

      if (response.data == null || response.data!.isEmpty) {
        throw Exception('HTML data is empty');
      }

      return response.data!;
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to download prescription');
    } catch (e) {
      throw Exception('Failed to download prescription: $e');
    }
  }

  String _handleDioError(DioException e, String defaultMessage) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please try again.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        final message = _extractErrorMessage(data) ?? defaultMessage;

        switch (statusCode) {
          case 401:
            return 'Unauthorized. Please login again.';
          case 403:
            return 'You do not have permission to access this resource.';
          case 404:
            return 'Resource not found.';
          case 500:
            return 'Server error. Please try again later.';
          default:
            return message;
        }
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      default:
        return defaultMessage;
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey('detail')) {
        return data['detail'] as String?;
      }
      if (data.containsKey('message')) {
        return data['message'] as String?;
      }
    }
    return null;
  }
}
