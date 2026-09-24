import 'package:equatable/equatable.dart';
import '../../../cases/domain/entities/court.dart';
import '../../../lookups/domain/entities/lookup.dart';
import 'service_status.dart';

class ServiceProcess extends Equatable {
  const ServiceProcess({
    required this.id,
    required this.caseId,
    required this.targetName,
    required this.serviceMethodId,
    required this.scheduledAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.courtId,
    this.court,
    this.hearingId,
    this.targetOpponentSnapshotId,
    this.serviceMethod,
    this.deadlineAt,
    this.servedAt,
    this.processServerName,
    this.notes,
    this.assignedUserId,
    this.recipientDetails,
    this.resultNotes,
    this.completedAt,
  });

  final String id;
  final String caseId;
  final String targetName;
  final String serviceMethodId;
  final DateTime scheduledAt;
  final ServiceStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? courtId;
  final Court? court;
  final String? hearingId;
  final String? targetOpponentSnapshotId;
  final Lookup? serviceMethod;
  final DateTime? deadlineAt;
  final DateTime? servedAt;
  final String? processServerName;
  final String? notes;
  final String? assignedUserId;
  final String? recipientDetails;
  final String? resultNotes;
  final DateTime? completedAt;

  factory ServiceProcess.fromJson(Map<String, dynamic> json) => ServiceProcess(
    id: json['id'] as String,
    caseId: json['caseId'] as String,
    targetName: json['targetName'] as String,
    serviceMethodId: json['serviceMethodId'] as String,
    scheduledAt: DateTime.parse(json['scheduledAt'] as String),
    status: serviceStatusFromJson(json['status']),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    courtId: json['courtId'] as String?,
    court: json['court'] is Map<String, dynamic>
        ? Court.fromJson(json['court'] as Map<String, dynamic>)
        : null,
    hearingId: json['hearingId'] as String?,
    targetOpponentSnapshotId: json['targetOpponentSnapshotId'] as String?,
    serviceMethod: json['serviceMethod'] is Map<String, dynamic>
        ? Lookup.fromJson(json['serviceMethod'] as Map<String, dynamic>)
        : null,
    deadlineAt: _date(json['deadlineAt']),
    servedAt: _date(json['servedAt']),
    processServerName: json['processServerName'] as String?,
    notes: json['notes'] as String?,
    assignedUserId: json['assignedUserId'] as String?,
    recipientDetails: json['recipientDetails'] as String?,
    resultNotes: json['resultNotes'] as String?,
    completedAt: _date(json['completedAt']),
  );

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;

  @override
  List<Object?> get props => [
    id,
    caseId,
    targetName,
    serviceMethodId,
    scheduledAt,
    status,
    courtId,
    hearingId,
    targetOpponentSnapshotId,
    deadlineAt,
    servedAt,
    processServerName,
    notes,
    assignedUserId,
    recipientDetails,
    resultNotes,
    completedAt,
  ];
}
