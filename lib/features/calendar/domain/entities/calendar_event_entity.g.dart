// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CalendarEventEntity _$CalendarEventEntityFromJson(Map<String, dynamic> json) =>
    _CalendarEventEntity(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      userId: json['userId'] as String,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      title: json['title'] as String,
      description: json['description'] as String?,
      eventType: $enumDecode(
        _$CalendarEventTypeEnumMap,
        json['eventType'],
        unknownValue: CalendarEventType.unknown,
      ),
      referenceId: json['referenceId'] as String?,
      startsAt: DateTime.parse(json['startsAt'] as String),
      endsAt: json['endsAt'] == null
          ? null
          : DateTime.parse(json['endsAt'] as String),
      location: json['location'] as String?,
      isAllDay: json['isAllDay'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CalendarEventEntityToJson(
  _CalendarEventEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'tenantId': instance.tenantId,
  'userId': instance.userId,
  'user': instance.user,
  'title': instance.title,
  'description': instance.description,
  'eventType': _$CalendarEventTypeEnumMap[instance.eventType]!,
  'referenceId': instance.referenceId,
  'startsAt': instance.startsAt.toIso8601String(),
  'endsAt': instance.endsAt?.toIso8601String(),
  'location': instance.location,
  'isAllDay': instance.isAllDay,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$CalendarEventTypeEnumMap = {
  CalendarEventType.hearing: 'HEARING',
  CalendarEventType.taskDeadline: 'TASK_DEADLINE',
  CalendarEventType.custom: 'CUSTOM',
  CalendarEventType.unknown: 'unknown',
};
