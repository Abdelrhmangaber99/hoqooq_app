// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hearing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Hearing _$HearingFromJson(Map<String, dynamic> json) => _Hearing(
  id: json['id'] as String,
  caseId: json['caseId'] as String,
  caseSummary: json['case'] == null
      ? null
      : CaseSummary.fromJson(json['case'] as Map<String, dynamic>),
  courtId: json['courtId'] as String,
  court: json['court'] == null
      ? null
      : Court.fromJson(json['court'] as Map<String, dynamic>),
  circuitId: json['circuitId'] as String?,
  hearingTypeId: json['hearingTypeId'] as String,
  scheduledAt: DateTime.parse(json['scheduledAt'] as String),
  judgeName: json['judgeName'] as String?,
  status: $enumDecode(
    _$HearingStatusEnumMap,
    json['status'],
    unknownValue: HearingStatus.unknown,
  ),
  outcomeText: json['outcomeText'] as String?,
  nextHearingAt: json['nextHearingAt'] == null
      ? null
      : DateTime.parse(json['nextHearingAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$HearingToJson(_Hearing instance) => <String, dynamic>{
  'id': instance.id,
  'caseId': instance.caseId,
  'case': instance.caseSummary,
  'courtId': instance.courtId,
  'court': instance.court,
  'circuitId': instance.circuitId,
  'hearingTypeId': instance.hearingTypeId,
  'scheduledAt': instance.scheduledAt.toIso8601String(),
  'judgeName': instance.judgeName,
  'status': _$HearingStatusEnumMap[instance.status]!,
  'outcomeText': instance.outcomeText,
  'nextHearingAt': instance.nextHearingAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$HearingStatusEnumMap = {
  HearingStatus.scheduled: 'SCHEDULED',
  HearingStatus.completed: 'COMPLETED',
  HearingStatus.adjourned: 'ADJOURNED',
  HearingStatus.cancelled: 'CANCELLED',
  HearingStatus.unknown: 'unknown',
};
