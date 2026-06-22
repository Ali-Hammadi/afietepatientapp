import 'package:afiete/core/usecases/usecase.dart';
import 'package:afiete/core/error/failure.dart';
import 'package:afiete/feature/payment/domain/entities/payment_entity.dart';
import 'package:afiete/feature/payment/domain/entities/payment_request_entity.dart';
import 'package:afiete/feature/payment/domain/repositories/payment_repository.dart';
import 'package:dartz/dartz.dart';

class ProcessPaymentUseCase
    implements UseCase<PaymentEntity, PaymentRequestEntity> {
  final PaymentRepository repository;

  ProcessPaymentUseCase(this.repository);

  @override
  Future<Either<Failure, PaymentEntity>> call(PaymentRequestEntity params) {
    return repository.processPayment(params);
  }
}
