class CreateServiceProcessRequest {
  const CreateServiceProcessRequest({
    required this.caseId,
    required this.targetName,
    required this.serviceMethodId,
    required this.scheduledAt,
    this.courtId,
    this.targetOpponentSnapshotId,
    this.deadlineAt,
    this.processServerName,
    this.recipientDetails,
    this.notes,
  });

  final String caseId;
  final String targetName;
  final String serviceMethodId;
  final DateTime scheduledAt;
  final String? courtId;
  final String? targetOpponentSnapshotId;
  final DateTime? deadlineAt;
  final String? processServerName;
  final String? recipientDetails;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'caseId': caseId,
    'targetName': targetName,
    'serviceMethodId': serviceMethodId,
    'scheduledAt': scheduledAt.toIso8601String(),
    if (courtId != null) 'courtId': courtId,
    if (targetOpponentSnapshotId != null)
      'targetOpponentSnapshotId': targetOpponentSnapshotId,
    if (deadlineAt != null) 'deadlineAt': deadlineAt!.toIso8601String(),
    if (processServerName != null) 'processServerName': processServerName,
    if (recipientDetails != null) 'recipientDetails': recipientDetails,
    if (notes != null) 'notes': notes,
  };
}
