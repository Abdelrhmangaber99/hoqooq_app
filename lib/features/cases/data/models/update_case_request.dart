/// Request body for `PATCH /cases/{id}`. Null fields are omitted so unchanged
/// Case values are not overwritten.
///
/// Every key here must exist on the deployed backend's `UpdateCaseDto`: its
/// global ValidationPipe runs with `whitelist: true` and
/// `forbidNonWhitelisted: true`, so one extra key fails the entire request
/// with a 400 instead of being ignored. `caseNumber`, `courtName` and
/// `priority` are *not* in that DTO (verified against the deployed Swagger,
/// HOQOOQ v3) — sending them is what made the Edit-Case screen error on save.
class UpdateCaseRequest {
  const UpdateCaseRequest({
    this.title,
    this.courtCaseNumber,
    this.courtCaseYear,
    this.caseTypeId,
    this.primaryLawyerId,
    this.governorateId,
    this.defaultCourtId,
    this.circuitId,
    this.openingDate,
    this.description,
    this.agreedFee,
  });

  final String? title;
  final String? courtCaseNumber;
  final int? courtCaseYear;
  final String? caseTypeId;
  final String? primaryLawyerId;
  final String? governorateId;
  final String? defaultCourtId;
  final String? circuitId;
  final DateTime? openingDate;
  final String? description;
  final double? agreedFee;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'title': title,
    'courtCaseNumber': courtCaseNumber,
    'courtCaseYear': courtCaseYear,
    'caseTypeId': caseTypeId,
    'primaryLawyerId': primaryLawyerId,
    'governorateId': governorateId,
    'defaultCourtId': defaultCourtId,
    'circuitId': circuitId,
    'openingDate': openingDate?.toIso8601String(),
    'description': description,
    'agreedFee': agreedFee,
  }..removeWhere((_, value) => value == null);
}
