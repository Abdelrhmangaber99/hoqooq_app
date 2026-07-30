// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CaseSummary _$CaseSummaryFromJson(Map<String, dynamic> json) => _CaseSummary(
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
  primaryLawyerId: json['primaryLawyerId'] as String?,
  defaultCourtId: json['defaultCourtId'] as String?,
  priority: $enumDecode(
    _$CasePriorityEnumMap,
    json['priority'],
    unknownValue: CasePriority.unknown,
  ),
  openingDate: json['openingDate'] == null
      ? null
      : DateTime.parse(json['openingDate'] as String),
  closingDate: json['closingDate'] == null
      ? null
      : DateTime.parse(json['closingDate'] as String),
  outcomeSummary: json['outcomeSummary'] as String?,
  agreedFee: (json['agreedFee'] as num?)?.toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CaseSummaryToJson(_CaseSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'caseNumber': instance.caseNumber,
      'status': _$CaseStatusEnumMap[instance.status]!,
      'clientId': instance.clientId,
      'caseTypeId': instance.caseTypeId,
      'primaryLawyerId': instance.primaryLawyerId,
      'defaultCourtId': instance.defaultCourtId,
      'priority': _$CasePriorityEnumMap[instance.priority]!,
      'openingDate': instance.openingDate?.toIso8601String(),
      'closingDate': instance.closingDate?.toIso8601String(),
      'outcomeSummary': instance.outcomeSummary,
      'agreedFee': instance.agreedFee,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
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
