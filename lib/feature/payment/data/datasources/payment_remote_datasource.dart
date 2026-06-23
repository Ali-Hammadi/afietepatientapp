import 'package:afiete/core/network/api_endpoints.dart';
import 'package:afiete/feature/payment/data/models/payment_model.dart';
import 'package:afiete/feature/payment/domain/entities/payment_request_entity.dart';
import 'package:dio/dio.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentModel> processPayment(PaymentRequestEntity request);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  PaymentRemoteDataSourceImpl({required Dio dio});

  @override
  Future<PaymentModel> processPayment(PaymentRequestEntity request) async {
    try {
      // محاكاة تأخير بسيط كأنها شبكة حقيقية (مثلاً نصف ثانية)
      await Future.delayed(const Duration(milliseconds: 500));

      // توليد بيانات دفع وهمية ناجحة ومكتملة بشكل نظامي بعمولة صفر
      final mockResponse = {
        'id': 'mock_pay_${DateTime.now().millisecondsSinceEpoch}',
        'transaction_ref': 'REF-${DateTime.now().microsecondsSinceEpoch}',
        'amount': request.amount, // القيمة المطلوبة بدون عمولات
        'currency': request.currency,
        'method': request.method.name,
        'status': 'success', // حالة الدفع ناجحة دائماً لتكمل الحجز
        'created_at': DateTime.now().toIso8601String(),
      };

      return PaymentModel.fromJson(mockResponse);
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.appointmentPayment),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }
}
