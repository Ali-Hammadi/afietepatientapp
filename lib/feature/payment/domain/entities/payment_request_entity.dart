import 'package:afiete/core/constants/payment_methods.dart';
import 'package:equatable/equatable.dart';

class PaymentRequestEntity extends Equatable {
  final int appointmentId;
  final double amount;
  final String currency;
  final PaymentMethod method;

  const PaymentRequestEntity({
    required this.appointmentId,
    required this.amount,
    this.currency = 'USD',
    required this.method,
  });

  @override
  List<Object?> get props => [
        appointmentId,
        amount,
        currency,
        method,
      ];
}
