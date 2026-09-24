/// Request body for `PATCH /hearings/{id}/complete`.
class CompleteHearingRequest {
  const CompleteHearingRequest({
    required this.outcomeText,
    this.nextHearingAt,
    this.minutesDocumentId,
  });

  final String outcomeText;
  final DateTime? nextHearingAt;
  final String? minutesDocumentId;

  Map<String, dynamic> toJson() => {
    'outcomeText': outcomeText,
    if (nextHearingAt != null) 'nextHearingAt': nextHearingAt!.toIso8601String(),
    if (minutesDocumentId != null) 'minutesDocumentId': minutesDocumentId,
  };
}
