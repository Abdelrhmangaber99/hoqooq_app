// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_hearing_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateHearingRequest _$UpdateHearingRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateHearingRequest(
  courtId: json['courtId'] as String?,
  scheduledAt: json['scheduledAt'] == null
      ? null
      : DateTime.parse(json['scheduledAt'] as String),
  judgeName: json['judgeName'] as String?,
  status: $enumDecodeNullable(_$HearingStatusEnumMap, json['status']),
  outcomeText: json['outcomeText'] as String?,
  nextHearingAt: json['nextHearingAt'] == null
      ? null
      : DateTime.parse(json['nextHearingAt'] as String),
);

Map<String, dynamic> _$UpdateHearingRequestToJson(
  _UpdateHearingRequest instance,
) => <String, dynamic>{
  'courtId': ?instance.courtId,
  'scheduledAt': ?instance.scheduledAt?.toIso8601String(),
  'judgeName': ?instance.judgeName,
  'status': ?_$HearingStatusEnumMap[instance.status],
  'outcomeText': ?instance.outcomeText,
  'nextHearingAt': ?instance.nextHearingAt?.toIso8601String(),
};

const _$HearingStatusEnumMap = {
  HearingStatus.scheduled: 'SCHEDULED',
  HearingStatus.completed: 'COMPLETED',
  HearingStatus.adjourned: 'POSTPONED',
  HearingStatus.missed: 'MISSED',
  HearingStatus.cancelled: 'CANCELLED',
  HearingStatus.unknown: 'unknown',
};
