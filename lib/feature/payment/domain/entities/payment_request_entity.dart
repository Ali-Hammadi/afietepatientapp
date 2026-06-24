import 'package:afiete/core/constants/payment_methods.dart';
import 'package:equatable/equatable.dart';

class PaymentRequestEntity extends Equatable {
  final dynamic appointmentId;
  final double amount;
  final String currency;
  final PaymentMethod method;

  // الحقول الجديدة التي تحتاجها شاشة ملخص الدفع
  final String sessionType;
  final String doctorName;
  final DateTime scheduledAt;

  const PaymentRequestEntity({
    required this.appointmentId,
    required this.amount,
    this.currency = 'USD',
    required this.method,
    required this.sessionType,
    required this.doctorName,
    required this.scheduledAt,
  });

  @override
  List<Object?> get props => [
        appointmentId,
        amount,
        currency,
        method,
        sessionType,
        doctorName,
        scheduledAt,
      ];
}
