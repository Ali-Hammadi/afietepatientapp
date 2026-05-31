import 'package:afietepatientapp/core/error/failure.dart';
import 'package:afietepatientapp/core/usecases/usecase.dart';
import 'package:afietepatientapp/feature/payment/domain/entities/payment_entity.dart';
import 'package:afietepatientapp/feature/payment/domain/repositories/payment_repository.dart';
import 'package:dartz/dartz.dart';

class ProcessPaymentUseCase
    implements UseCase<PaymentEntity, PaymentRequestEntity> {
  final PaymentRepository repository;

  const ProcessPaymentUseCase(this.repository);

  @override
  Future<Either<Failure, PaymentEntity>> call(PaymentRequestEntity params) {
    return repository.processPayment(params);
  }
}
