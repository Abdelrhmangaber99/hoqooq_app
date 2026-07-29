import 'package:freezed_annotation/freezed_annotation.dart';

part 'appointment.freezed.dart';

@freezed
abstract class Appointment with _$Appointment {
  const Appointment._();
  const factory Appointment({
    required String id,
    required String title,
    required String clientName,
    required DateTime date,
    required String time,
    required String location,
    required String type,
    String? notes,
  }) = _Appointment;
}
