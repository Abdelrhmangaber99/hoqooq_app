import '../../domain/entities/service_status.dart';

class CompleteServiceProcessRequest {
  const CompleteServiceProcessRequest({
    required this.status,
    required this.resultNotes,
    required this.documentId,
  });

  final ServiceStatus status;
  final String resultNotes;
  final String documentId;

  Map<String, dynamic> toJson() => {
    'status': serviceStatusToJson(status),
    'resultNotes': resultNotes,
    'documentId': documentId,
  };
}
