// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_case_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateCaseRequest _$UpdateCaseRequestFromJson(Map<String, dynamic> json) =>
    _UpdateCaseRequest(
      defaultCourtId: json['defaultCourtId'] as String?,
      status: $enumDecodeNullable(_$CaseStatusEnumMap, json['status']),
      openingDate: json['openingDate'] == null
          ? null
          : DateTime.parse(json['openingDate'] as String),
      closingDate: json['closingDate'] == null
          ? null
          : DateTime.parse(json['closingDate'] as String),
      outcomeSummary: json['outcomeSummary'] as String?,
      agreedFee: (json['agreedFee'] as num?)?.toDouble(),
      priority: $enumDecodeNullable(_$CasePriorityEnumMap, json['priority']),
    );

Map<String, dynamic> _$UpdateCaseRequestToJson(_UpdateCaseRequest instance) =>
    <String, dynamic>{
      'defaultCourtId': ?instance.defaultCourtId,
      'status': ?_$CaseStatusEnumMap[instance.status],
      'openingDate': ?instance.openingDate?.toIso8601String(),
      'closingDate': ?instance.closingDate?.toIso8601String(),
      'outcomeSummary': ?instance.outcomeSummary,
      'agreedFee': ?instance.agreedFee,
      'priority': ?_$CasePriorityEnumMap[instance.priority],
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
