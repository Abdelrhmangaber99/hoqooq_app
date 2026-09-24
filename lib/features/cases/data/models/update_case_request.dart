import '../../domain/entities/case_priority.dart';

/// Request body for `PATCH /cases/{id}`. Null fields are omitted so unchanged
/// Case values are not overwritten.
class UpdateCaseRequest {
  const UpdateCaseRequest({
    this.caseNumber,
    this.title,
    this.courtCaseNumber,
    this.courtCaseYear,
    this.caseTypeId,
    this.primaryLawyerId,
    this.governorateId,
    this.defaultCourtId,
    this.circuitId,
    this.courtName,
    this.openingDate,
    this.description,
    this.agreedFee,
    this.priority,
  });

  final String? caseNumber;
  final String? title;
  final String? courtCaseNumber;
  final int? courtCaseYear;
  final String? caseTypeId;
  final String? primaryLawyerId;
  final String? governorateId;
  final String? defaultCourtId;
  final String? circuitId;
  final String? courtName;
  final DateTime? openingDate;
  final String? description;
  final double? agreedFee;
  final CasePriority? priority;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'caseNumber': caseNumber,
    'title': title,
    'courtCaseNumber': courtCaseNumber,
    'courtCaseYear': courtCaseYear,
    'caseTypeId': caseTypeId,
    'primaryLawyerId': primaryLawyerId,
    'governorateId': governorateId,
    'defaultCourtId': defaultCourtId,
    'circuitId': circuitId,
    'courtName': courtName,
    'openingDate': openingDate?.toIso8601String(),
    'description': description,
    'agreedFee': agreedFee,
    'priority': priority?.name.toUpperCase(),
  }..removeWhere((_, value) => value == null);
}
