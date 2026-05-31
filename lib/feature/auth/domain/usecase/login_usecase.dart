import 'package:dartz/dartz.dart';
import 'package:afietepatientapp/core/error/failure.dart';
import 'package:afietepatientapp/core/usecases/usecase.dart';
import 'package:afietepatientapp/feature/auth/domain/entities/auth_user_entity.dart';
import 'package:afietepatientapp/feature/auth/domain/repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;
  final String? correlationId;

  const LoginParams({
    required this.email,
    required this.password,
    this.correlationId,
  });
}

class LoginUseCase implements UseCase<UserAuthEntity, LoginParams> {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  @override
  Future<Either<Failure, UserAuthEntity>> call(LoginParams params) async {
    return await repository.login(
      email: params.email,
      password: params.password,
      correlationId: params.correlationId,
    );
  }
}
