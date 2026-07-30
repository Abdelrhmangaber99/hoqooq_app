// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'legal_case.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LegalCase _$LegalCaseFromJson(Map<String, dynamic> json) => _LegalCase(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  caseNumber: json['caseNumber'] as String,
  status: $enumDecode(
    _$CaseStatusEnumMap,
    json['status'],
    unknownValue: CaseStatus.unknown,
  ),
  clientId: json['clientId'] as String,
  caseTypeId: json['caseTypeId'] as String,
  priority: $enumDecode(
    _$CasePriorityEnumMap,
    json['priority'],
    unknownValue: CasePriority.unknown,
  ),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  client: Client.fromJson(json['client'] as Map<String, dynamic>),
  primaryLawyerId: json['primaryLawyerId'] as String?,
  primaryLawyer: json['primaryLawyer'] == null
      ? null
      : User.fromJson(json['primaryLawyer'] as Map<String, dynamic>),
  caseType: json['caseType'] == null
      ? null
      : CaseTypeLookup.fromJson(json['caseType'] as Map<String, dynamic>),
  defaultCourtId: json['defaultCourtId'] as String?,
  defaultCourt: json['defaultCourt'] == null
      ? null
      : Court.fromJson(json['defaultCourt'] as Map<String, dynamic>),
  openingDate: json['openingDate'] == null
      ? null
      : DateTime.parse(json['openingDate'] as String),
  closingDate: json['closingDate'] == null
      ? null
      : DateTime.parse(json['closingDate'] as String),
  outcomeSummary: json['outcomeSummary'] as String?,
  agreedFee: (json['agreedFee'] as num?)?.toDouble(),
  team: (json['team'] as List<dynamic>)
      .map((e) => CaseTeamMember.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LegalCaseToJson(_LegalCase instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'caseNumber': instance.caseNumber,
      'status': _$CaseStatusEnumMap[instance.status]!,
      'clientId': instance.clientId,
      'caseTypeId': instance.caseTypeId,
      'priority': _$CasePriorityEnumMap[instance.priority]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'client': instance.client,
      'primaryLawyerId': instance.primaryLawyerId,
      'primaryLawyer': instance.primaryLawyer,
      'caseType': instance.caseType,
      'defaultCourtId': instance.defaultCourtId,
      'defaultCourt': instance.defaultCourt,
      'openingDate': instance.openingDate?.toIso8601String(),
      'closingDate': instance.closingDate?.toIso8601String(),
      'outcomeSummary': instance.outcomeSummary,
      'agreedFee': instance.agreedFee,
      'team': instance.team,
    };

const _$CaseStatusEnumMap = {
  CaseStatus.draft: 'DRAFT',
  CaseStatus.active: 'ACTIVE',
  CaseStatus.suspended: 'SUSPENDED',
  CaseStatus.closed: 'CLOSED',
  CaseStatus.archived: 'ARCHIVED',
  CaseStatus.unknown: 'unknown',
};

const _$CasePriorityEnumMap = {
  CasePriority.low: 'LOW',
  CasePriority.normal: 'NORMAL',
  CasePriority.high: 'HIGH',
  CasePriority.urgent: 'URGENT',
  CasePriority.unknown: 'unknown',
};
