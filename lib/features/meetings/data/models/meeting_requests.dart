class CreateMeetingRequest {
  const CreateMeetingRequest({
    required this.caseId,
    required this.scheduledAt,
    required this.locationOrMethod,
    required this.subject,
    this.notes,
  });
  final String caseId;
  final DateTime scheduledAt;
  final String locationOrMethod;
  final String subject;
  final String? notes;
  Map<String, dynamic> toJson() => {
    'caseId': caseId,
    'scheduledAt': scheduledAt.toIso8601String(),
    'locationOrMethod': locationOrMethod,
    'subject': subject,
    if (notes != null) 'notes': notes,
  };
}

class UpdateMeetingRequest {
  const UpdateMeetingRequest({
    this.scheduledAt,
    this.locationOrMethod,
    this.subject,
    this.notes,
  });
  final DateTime? scheduledAt;
  final String? locationOrMethod;
  final String? subject;
  final String? notes;
  Map<String, dynamic> toJson() => {
    if (scheduledAt != null) 'scheduledAt': scheduledAt!.toIso8601String(),
    if (locationOrMethod != null) 'locationOrMethod': locationOrMethod,
    if (subject != null) 'subject': subject,
    if (notes != null) 'notes': notes,
  };
}
