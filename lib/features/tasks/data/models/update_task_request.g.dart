// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_task_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateTaskRequest _$UpdateTaskRequestFromJson(Map<String, dynamic> json) =>
    _UpdateTaskRequest(
      status: $enumDecodeNullable(_$TaskStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$UpdateTaskRequestToJson(_UpdateTaskRequest instance) =>
    <String, dynamic>{'status': ?_$TaskStatusEnumMap[instance.status]};

const _$TaskStatusEnumMap = {
  TaskStatus.newTask: 'TODO',
  TaskStatus.inProgress: 'IN_PROGRESS',
  TaskStatus.waiting: 'WAITING',
  TaskStatus.completed: 'COMPLETED',
  TaskStatus.cancelled: 'CANCELLED',
  TaskStatus.unknown: 'unknown',
};
