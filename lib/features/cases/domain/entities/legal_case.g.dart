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
  caseTypeId: json['caseTypeId'] as String,
  priority: $enumDecode(
    _$CasePriorityEnumMap,
    json['priority'],
    unknownValue: CasePriority.unknown,
  ),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  clientSnapshot: json['clientSnapshot'] == null
      ? null
      : CaseClientSnapshot.fromJson(
          json['clientSnapshot'] as Map<String, dynamic>,
        ),
  opponentSnapshots: (json['opponentSnapshots'] as List<dynamic>?)
      ?.map((e) => CaseOpponentSnapshot.fromJson(e as Map<String, dynamic>))
      .toList(),
  caseType: json['caseType'] == null
      ? null
      : CaseTypeLookup.fromJson(json['caseType'] as Map<String, dynamic>),
  title: json['title'] as String?,
  courtCaseNumber: json['courtCaseNumber'] as String?,
  courtCaseYear: (json['courtCaseYear'] as num?)?.toInt(),
  governorateId: json['governorateId'] as String?,
  circuitId: json['circuitId'] as String?,
  ownerFirmAdminId: json['ownerFirmAdminId'] as String?,
  primaryLawyerId: json['primaryLawyerId'] as String?,
  description: json['description'] as String?,
  courtName: json['courtName'] as String?,
  openingDate: json['openingDate'] == null
      ? null
      : DateTime.parse(json['openingDate'] as String),
  closingDate: json['closingDate'] == null
      ? null
      : DateTime.parse(json['closingDate'] as String),
  outcomeSummary: json['outcomeSummary'] as String?,
  team: (json['team'] as List<dynamic>)
      .map((e) => CaseTeamMember.fromJson(e as Map<String, dynamic>))
      .toList(),
  timelineEvents: _timelineFromJson(json['timelineEvents'] as List?),
);

Map<String, dynamic> _$LegalCaseToJson(_LegalCase instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'caseNumber': instance.caseNumber,
      'status': _$CaseStatusEnumMap[instance.status]!,
      'caseTypeId': instance.caseTypeId,
      'priority': _$CasePriorityEnumMap[instance.priority]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'clientSnapshot': instance.clientSnapshot,
      'opponentSnapshots': instance.opponentSnapshots,
      'caseType': instance.caseType,
      'title': instance.title,
      'courtCaseNumber': instance.courtCaseNumber,
      'courtCaseYear': instance.courtCaseYear,
      'governorateId': instance.governorateId,
      'circuitId': instance.circuitId,
      'ownerFirmAdminId': instance.ownerFirmAdminId,
      'primaryLawyerId': instance.primaryLawyerId,
      'description': instance.description,
      'courtName': instance.courtName,
      'openingDate': instance.openingDate?.toIso8601String(),
      'closingDate': instance.closingDate?.toIso8601String(),
      'outcomeSummary': instance.outcomeSummary,
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
