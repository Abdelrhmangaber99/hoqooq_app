class UpdateServiceProcessRequest {
  const UpdateServiceProcessRequest({
    this.courtId,
    this.targetName,
    this.serviceMethodId,
    this.scheduledAt,
    this.deadlineAt,
    this.processServerName,
    this.recipientDetails,
    this.notes,
  });

  final String? courtId;
  final String? targetName;
  final String? serviceMethodId;
  final DateTime? scheduledAt;
  final DateTime? deadlineAt;
  final String? processServerName;
  final String? recipientDetails;
  final String? notes;

  Map<String, dynamic> toJson() => {
    if (courtId != null) 'courtId': courtId,
    if (targetName != null) 'targetName': targetName,
    if (serviceMethodId != null) 'serviceMethodId': serviceMethodId,
    if (scheduledAt != null) 'scheduledAt': scheduledAt!.toIso8601String(),
    if (deadlineAt != null) 'deadlineAt': deadlineAt!.toIso8601String(),
    if (processServerName != null) 'processServerName': processServerName,
    if (recipientDetails != null) 'recipientDetails': recipientDetails,
    if (notes != null) 'notes': notes,
  };
}
