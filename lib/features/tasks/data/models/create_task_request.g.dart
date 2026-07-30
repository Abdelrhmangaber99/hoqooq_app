// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_task_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateTaskRequest _$CreateTaskRequestFromJson(Map<String, dynamic> json) =>
    _CreateTaskRequest(
      caseId: json['caseId'] as String?,
      assignedById: json['assignedById'] as String,
      assignedToId: json['assignedToId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      priority: $enumDecodeNullable(_$TaskPriorityEnumMap, json['priority']),
      status: $enumDecodeNullable(_$TaskStatusEnumMap, json['status']),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
    );

Map<String, dynamic> _$CreateTaskRequestToJson(_CreateTaskRequest instance) =>
    <String, dynamic>{
      'caseId': instance.caseId,
      'assignedById': instance.assignedById,
      'assignedToId': instance.assignedToId,
      'title': instance.title,
      'description': instance.description,
      'priority': _$TaskPriorityEnumMap[instance.priority],
      'status': _$TaskStatusEnumMap[instance.status],
      'dueDate': instance.dueDate?.toIso8601String(),
    };

const _$TaskPriorityEnumMap = {
  TaskPriority.low: 'LOW',
  TaskPriority.normal: 'NORMAL',
  TaskPriority.high: 'HIGH',
  TaskPriority.urgent: 'URGENT',
  TaskPriority.unknown: 'unknown',
};

const _$TaskStatusEnumMap = {
  TaskStatus.pending: 'PENDING',
  TaskStatus.inProgress: 'IN_PROGRESS',
  TaskStatus.completed: 'COMPLETED',
  TaskStatus.cancelled: 'CANCELLED',
  TaskStatus.unknown: 'unknown',
};
