// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_task_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateTaskRequest _$CreateTaskRequestFromJson(Map<String, dynamic> json) =>
    _CreateTaskRequest(
      caseId: json['caseId'] as String,
      assignedToId: json['assignedToId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      priority: $enumDecodeNullable(_$TaskPriorityEnumMap, json['priority']),
      status: $enumDecodeNullable(_$TaskStatusEnumMap, json['status']),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      linkedEntityType: json['linkedEntityType'] as String?,
      linkedEntityId: json['linkedEntityId'] as String?,
    );

Map<String, dynamic> _$CreateTaskRequestToJson(_CreateTaskRequest instance) =>
    <String, dynamic>{
      'caseId': instance.caseId,
      'assignedToId': instance.assignedToId,
      'title': instance.title,
      'description': instance.description,
      'priority': _$TaskPriorityEnumMap[instance.priority],
      'status': _$TaskStatusEnumMap[instance.status],
      'dueDate': instance.dueDate?.toIso8601String(),
      'linkedEntityType': instance.linkedEntityType,
      'linkedEntityId': instance.linkedEntityId,
    };

const _$TaskPriorityEnumMap = {
  TaskPriority.low: 'LOW',
  TaskPriority.normal: 'MEDIUM',
  TaskPriority.high: 'HIGH',
  TaskPriority.urgent: 'URGENT',
  TaskPriority.unknown: 'unknown',
};

const _$TaskStatusEnumMap = {
  TaskStatus.newTask: 'TODO',
  TaskStatus.inProgress: 'IN_PROGRESS',
  TaskStatus.waiting: 'WAITING',
  TaskStatus.completed: 'COMPLETED',
  TaskStatus.cancelled: 'CANCELLED',
  TaskStatus.unknown: 'unknown',
};
