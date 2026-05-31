import 'package:afietepatientapp/core/error/failure.dart';
import 'package:afietepatientapp/feature/payment/data/datasources/payment_remote_datasource.dart';
import 'package:afietepatientapp/feature/payment/domain/entities/payment_entity.dart';
import 'package:afietepatientapp/feature/payment/domain/repositories/payment_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource dataSource;

  const PaymentRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, PaymentEntity>> processPayment(
    PaymentRequestEntity request,
  ) async {
    try {
      final result = await dataSource.processPayment(request);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (_) {
      return Left(ServerFailure('Unable to complete payment right now.'));
    }
  }
}
