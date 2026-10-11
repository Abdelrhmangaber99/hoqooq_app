import '../../domain/entities/service_status.dart';

class CompleteServiceProcessRequest {
  const CompleteServiceProcessRequest({
    required this.status,
    required this.resultNotes,
  });

  final ServiceStatus status;
  final String resultNotes;

  Map<String, dynamic> toJson() => {
    'status': serviceStatusToJson(status),
    'resultNotes': resultNotes,
  };
}
