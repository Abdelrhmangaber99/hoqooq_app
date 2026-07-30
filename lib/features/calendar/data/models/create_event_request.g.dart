// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_event_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateEventRequest _$CreateEventRequestFromJson(Map<String, dynamic> json) =>
    _CreateEventRequest(
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      eventType:
          $enumDecodeNullable(_$CalendarEventTypeEnumMap, json['eventType']) ??
          CalendarEventType.custom,
      startsAt: DateTime.parse(json['startsAt'] as String),
      endsAt: json['endsAt'] == null
          ? null
          : DateTime.parse(json['endsAt'] as String),
      location: json['location'] as String?,
      isAllDay: json['isAllDay'] as bool?,
    );

Map<String, dynamic> _$CreateEventRequestToJson(_CreateEventRequest instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'title': instance.title,
      'description': instance.description,
      'eventType': _$CalendarEventTypeEnumMap[instance.eventType]!,
      'startsAt': instance.startsAt.toIso8601String(),
      'endsAt': instance.endsAt?.toIso8601String(),
      'location': instance.location,
      'isAllDay': instance.isAllDay,
    };

const _$CalendarEventTypeEnumMap = {
  CalendarEventType.hearing: 'HEARING',
  CalendarEventType.taskDeadline: 'TASK_DEADLINE',
  CalendarEventType.custom: 'CUSTOM',
  CalendarEventType.unknown: 'unknown',
};
