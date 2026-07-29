import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../entities/appointment.dart';
import '../repository/i_appointment_repository.dart';

@lazySingleton
class GetAppointmentsUseCase {
  final IAppointmentRepository repository;

  GetAppointmentsUseCase(this.repository);

  ApiResult<List<Appointment>> execute({DateTime? date}) {
    return repository.getAppointments(date: date);
  }
}
