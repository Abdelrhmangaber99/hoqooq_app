import '../../../../core/network/api_result.dart';
import '../entities/appointment.dart';

abstract class IAppointmentRepository {
  ApiResult<List<Appointment>> getAppointments({DateTime? date});
  ApiResult<void> scheduleAppointment(Appointment appointment);
}
