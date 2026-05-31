import 'package:afietepatientapp/core/error/failure.dart';
import 'package:afietepatientapp/core/usecases/usecase.dart';
import 'package:afietepatientapp/feature/appoinments/domain/entities/appointment_entity.dart';
import 'package:afietepatientapp/feature/appoinments/domain/repositories/appointments_repository.dart';
import 'package:dartz/dartz.dart';

class GetAppointmentsUseCase
    implements UseCase<List<AppointmentEntity>, NoParams> {
  final AppointmentsRepository repository;

  const GetAppointmentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AppointmentEntity>>> call(NoParams params) {
    return repository.getAppointments();
  }
}
