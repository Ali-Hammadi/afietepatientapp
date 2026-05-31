import 'package:afietepatientapp/core/error/failure.dart';
import 'package:afietepatientapp/feature/payment/domain/entities/payment_entity.dart';
import 'package:dartz/dartz.dart';

abstract class PaymentRepository {
  Future<Either<Failure, PaymentEntity>> processPayment(
    PaymentRequestEntity request,
  );
}
