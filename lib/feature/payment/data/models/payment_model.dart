import 'package:afiete/core/constants/payment_methods.dart';
import 'package:afiete/feature/payment/domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.transactionRef,
    required super.amount,
    required super.currency,
    required super.method,
    required super.status,
    required super.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: (json['id'] ?? '').toString(),
      transactionRef: (json['transaction_ref'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: (json['currency'] ?? 'USD').toString(),
      method: _methodFromRaw(json['method'] ?? 'card'),
      status: _statusFromRaw(json['status'] ?? 'pending'),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  static PaymentMethod _methodFromRaw(String raw) {
    switch (raw.toLowerCase()) {
      case 'wallet':
        return PaymentMethod.wallet;
      case 'cash':
        return PaymentMethod.cash;
      default:
        return PaymentMethod.card;
    }
  }

  static PaymentStatus _statusFromRaw(String raw) {
    switch (raw.toLowerCase()) {
      case 'success':
      case 'paid':
        return PaymentStatus.success;
      case 'failed':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.pending;
    }
  }
}
