// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_hearing_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateHearingRequest _$CreateHearingRequestFromJson(
  Map<String, dynamic> json,
) => _CreateHearingRequest(
  caseId: json['caseId'] as String,
  courtId: json['courtId'] as String,
  hearingTypeId: json['hearingTypeId'] as String,
  scheduledAt: DateTime.parse(json['scheduledAt'] as String),
  circuitId: json['circuitId'] as String?,
  judgeName: json['judgeName'] as String?,
  status: $enumDecodeNullable(_$HearingStatusEnumMap, json['status']),
  outcomeText: json['outcomeText'] as String?,
  nextHearingAt: json['nextHearingAt'] == null
      ? null
      : DateTime.parse(json['nextHearingAt'] as String),
);

Map<String, dynamic> _$CreateHearingRequestToJson(
  _CreateHearingRequest instance,
) => <String, dynamic>{
  'caseId': instance.caseId,
  'courtId': instance.courtId,
  'hearingTypeId': instance.hearingTypeId,
  'scheduledAt': instance.scheduledAt.toIso8601String(),
  'circuitId': instance.circuitId,
  'judgeName': instance.judgeName,
  'status': _$HearingStatusEnumMap[instance.status],
  'outcomeText': instance.outcomeText,
  'nextHearingAt': instance.nextHearingAt?.toIso8601String(),
};

const _$HearingStatusEnumMap = {
  HearingStatus.scheduled: 'SCHEDULED',
  HearingStatus.completed: 'COMPLETED',
  HearingStatus.adjourned: 'ADJOURNED',
  HearingStatus.cancelled: 'CANCELLED',
  HearingStatus.unknown: 'unknown',
};
