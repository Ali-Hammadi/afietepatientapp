import 'package:dartz/dartz.dart';
import 'package:afietepatientapp/core/error/failure.dart';
import 'package:afietepatientapp/core/usecases/usecase.dart';
import 'package:afietepatientapp/feature/auth/domain/entities/auth_user_entity.dart';
import 'package:afietepatientapp/feature/auth/domain/repositories/auth_repository.dart';

class GoogleSignInParams {
  final String idToken;
  final String? correlationId;

  const GoogleSignInParams({required this.idToken, this.correlationId});
}

class GoogleSignInUseCase
    implements UseCase<UserAuthEntity, GoogleSignInParams> {
  final AuthRepository repository;

  const GoogleSignInUseCase(this.repository);

  @override
  Future<Either<Failure, UserAuthEntity>> call(
    GoogleSignInParams params,
  ) async {
    return await repository.googleSignIn(
      idToken: params.idToken,
      correlationId: params.correlationId,
    );
  }
}
