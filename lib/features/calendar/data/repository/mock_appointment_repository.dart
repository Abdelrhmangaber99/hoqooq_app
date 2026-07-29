import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repository/i_appointment_repository.dart';

@LazySingleton(as: IAppointmentRepository)
class MockAppointmentRepository implements IAppointmentRepository {
  @override
  ApiResult<List<Appointment>> getAppointments({DateTime? date}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return Right([
      Appointment(
        id: '1',
        title: 'Hernandez v. State',
        clientName: 'Carlos Hernandez',
        date: DateTime(2026, 7, 16),
        time: '09:00 AM',
        location: 'District Court',
        type: 'Hearing',
      ),
      Appointment(
        id: '2',
        title: 'Morrison Estate',
        clientName: 'Patricia Morrison',
        date: DateTime(2026, 7, 16),
        time: '11:30 AM',
        location: 'Office',
        type: 'Client Meeting',
      ),
    ]);
  }

  @override
  ApiResult<void> scheduleAppointment(Appointment appointment) async {
    return const Right(null);
  }
}
