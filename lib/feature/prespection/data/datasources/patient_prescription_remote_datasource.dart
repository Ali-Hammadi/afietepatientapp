import 'package:afiete/core/network/api_endpoints.dart';
import 'package:dio/dio.dart';
import '../models/prescription_model.dart';

class PatientPrescriptionRemoteDataSource {
  final Dio dio;
  final String baseUrl;
  final String Function() getToken;

  PatientPrescriptionRemoteDataSource({
    required this.dio,
    required this.baseUrl,
    required this.getToken,
  });

  Options get _options => Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${getToken()}',
        },
      );

  Future<List<PrescriptionModel>> getPrescriptions() async {
    try {
      final response = await dio.get(
        ApiEndpoints.prescription,
        options: _options,
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
      final response = await dio.get(
        ApiEndpoints.getPrescription(id),
        options: _options,
      );

      return PrescriptionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to load prescription detail');
    } catch (e) {
      throw Exception('Failed to load prescription detail: $e');
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
