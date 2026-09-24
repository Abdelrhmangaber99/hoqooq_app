enum CaseTimelineEventType {
  created,
  lawyerChanged,
  statusChanged,
  hearingScheduled,
  hearingCompleted,
  documentUploaded,
  noteAdded,
  paymentReceived,
  taskAssigned,
  serviceOfProcessAdded,
  serviceOfProcessUpdated,
  grantAdded,
  grantRevoked,
  unknown,
}

class CaseTimelineEvent {
  const CaseTimelineEvent({
    required this.id,
    required this.caseId,
    required this.eventType,
    required this.actorUserId,
    required this.createdAt,
    this.previousState,
    this.newState,
    this.note,
  });

  final String id;
  final String caseId;
  final CaseTimelineEventType eventType;
  final String actorUserId;
  final String? previousState;
  final String? newState;
  final String? note;
  final DateTime createdAt;

  factory CaseTimelineEvent.fromJson(Map<String, dynamic> json) =>
      CaseTimelineEvent(
        id: json['id'] as String,
        caseId: json['caseId'] as String,
        eventType: _eventTypeFromJson(json['eventType'] as String?),
        actorUserId: json['actorUserId'] as String,
        previousState: json['previousState'] as String?,
        newState: json['newState'] as String?,
        note: json['note'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

CaseTimelineEventType _eventTypeFromJson(String? value) {
  const values = {
    'CREATED': CaseTimelineEventType.created,
    'LAWYER_CHANGED': CaseTimelineEventType.lawyerChanged,
    'STATUS_CHANGED': CaseTimelineEventType.statusChanged,
    'HEARING_SCHEDULED': CaseTimelineEventType.hearingScheduled,
    'HEARING_COMPLETED': CaseTimelineEventType.hearingCompleted,
    'DOCUMENT_UPLOADED': CaseTimelineEventType.documentUploaded,
    'NOTE_ADDED': CaseTimelineEventType.noteAdded,
    'PAYMENT_RECEIVED': CaseTimelineEventType.paymentReceived,
    'TASK_ASSIGNED': CaseTimelineEventType.taskAssigned,
    'SERVICE_OF_PROCESS_ADDED': CaseTimelineEventType.serviceOfProcessAdded,
    'SERVICE_OF_PROCESS_UPDATED': CaseTimelineEventType.serviceOfProcessUpdated,
    'GRANT_ADDED': CaseTimelineEventType.grantAdded,
    'GRANT_REVOKED': CaseTimelineEventType.grantRevoked,
  };
  return values[value] ?? CaseTimelineEventType.unknown;
}
