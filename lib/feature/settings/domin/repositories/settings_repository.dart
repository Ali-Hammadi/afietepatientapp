// feature/settings/domin/repositories/settings_repository.dart
import 'package:afiete/core/error/failure.dart';
import 'package:dartz/dartz.dart';

abstract class SettingsRepository {
  Future<Either<Failure, String>> submitReportIssue({
    required String userId,
    required String reason,
    required String details,
  });
}
