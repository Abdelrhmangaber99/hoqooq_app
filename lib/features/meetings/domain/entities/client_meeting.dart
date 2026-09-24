import 'package:equatable/equatable.dart';
import 'meeting_status.dart';

class ClientMeeting extends Equatable {
  const ClientMeeting({
    required this.id,
    required this.caseId,
    required this.scheduledAt,
    required this.locationOrMethod,
    required this.subject,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.assignedUserId,
    this.notes,
    this.outcomeNotes,
  });

  final String id;
  final String caseId;
  final DateTime scheduledAt;
  final String locationOrMethod;
  final String subject;
  final MeetingStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? assignedUserId;
  final String? notes;
  final String? outcomeNotes;

  factory ClientMeeting.fromJson(Map<String, dynamic> json) => ClientMeeting(
    id: json['id'] as String,
    caseId: json['caseId'] as String,
    scheduledAt: DateTime.parse(json['scheduledAt'] as String),
    locationOrMethod: json['locationOrMethod'] as String,
    subject: json['subject'] as String,
    status: meetingStatusFromJson(json['status']),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    assignedUserId: json['assignedUserId'] as String?,
    notes: json['notes'] as String?,
    outcomeNotes: json['outcomeNotes'] as String?,
  );

  @override
  List<Object?> get props => [
    id,
    caseId,
    scheduledAt,
    locationOrMethod,
    subject,
    status,
    assignedUserId,
    notes,
    outcomeNotes,
  ];
}
