// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskItem _$TaskItemFromJson(Map<String, dynamic> json) => _TaskItem(
  id: json['id'] as String,
  caseId: json['caseId'] as String?,
  caseSummary: json['case'] == null
      ? null
      : CaseSummary.fromJson(json['case'] as Map<String, dynamic>),
  assignedById: json['assignedById'] as String,
  assignedBy: json['assignedBy'] == null
      ? null
      : User.fromJson(json['assignedBy'] as Map<String, dynamic>),
  assignedToId: json['assignedToId'] as String,
  assignedTo: json['assignedTo'] == null
      ? null
      : User.fromJson(json['assignedTo'] as Map<String, dynamic>),
  title: json['title'] as String,
  description: json['description'] as String?,
  priority: $enumDecode(
    _$TaskPriorityEnumMap,
    json['priority'],
    unknownValue: TaskPriority.unknown,
  ),
  status: $enumDecode(
    _$TaskStatusEnumMap,
    json['status'],
    unknownValue: TaskStatus.unknown,
  ),
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  linkedEntityType: json['linkedEntityType'] as String?,
  linkedEntityId: json['linkedEntityId'] as String?,
  completionNote: json['completionNote'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$TaskItemToJson(_TaskItem instance) => <String, dynamic>{
  'id': instance.id,
  'caseId': instance.caseId,
  'case': instance.caseSummary,
  'assignedById': instance.assignedById,
  'assignedBy': instance.assignedBy,
  'assignedToId': instance.assignedToId,
  'assignedTo': instance.assignedTo,
  'title': instance.title,
  'description': instance.description,
  'priority': _$TaskPriorityEnumMap[instance.priority]!,
  'status': _$TaskStatusEnumMap[instance.status]!,
  'dueDate': instance.dueDate?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'linkedEntityType': instance.linkedEntityType,
  'linkedEntityId': instance.linkedEntityId,
  'completionNote': instance.completionNote,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$TaskPriorityEnumMap = {
  TaskPriority.low: 'LOW',
  TaskPriority.normal: 'NORMAL',
  TaskPriority.high: 'HIGH',
  TaskPriority.urgent: 'URGENT',
  TaskPriority.unknown: 'unknown',
};

const _$TaskStatusEnumMap = {
  TaskStatus.newTask: 'NEW',
  TaskStatus.inProgress: 'IN_PROGRESS',
  TaskStatus.waiting: 'WAITING',
  TaskStatus.completed: 'COMPLETED',
  TaskStatus.cancelled: 'CANCELLED',
  TaskStatus.unknown: 'unknown',
};
