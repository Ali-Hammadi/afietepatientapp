import 'package:afiete/core/constants/payment_methods.dart';
import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final String id;
  final String transactionRef;
  final double amount;
  final String currency;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt;

  const PaymentEntity({
    required this.id,
    required this.transactionRef,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        transactionRef,
        amount,
        currency,
        method,
        status,
        createdAt,
      ];
}
