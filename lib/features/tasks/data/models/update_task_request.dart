import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_status.dart';

part 'update_task_request.freezed.dart';
part 'update_task_request.g.dart';

/// Request body for `PATCH /tasks/{id}` per `UpdateTaskDto`
/// (`PartialType(CreateTaskDto)` server-side). Every field is
/// `@JsonKey(includeIfNull: false)` for the same partial-PATCH reason as
/// `UpdateClientRequest`/`UpdateCaseRequest`/`UpdateHearingRequest` —
/// `TasksService.update` does a TypeORM `merge()`.
@freezed
abstract class UpdateTaskRequest with _$UpdateTaskRequest {
  const factory UpdateTaskRequest({
    @JsonKey(includeIfNull: false) String? caseId,
    @JsonKey(includeIfNull: false) String? assignedById,
    @JsonKey(includeIfNull: false) String? assignedToId,
    @JsonKey(includeIfNull: false) String? title,
    @JsonKey(includeIfNull: false) String? description,
    @JsonKey(includeIfNull: false) TaskPriority? priority,
    @JsonKey(includeIfNull: false) TaskStatus? status,
    @JsonKey(includeIfNull: false) DateTime? dueDate,
  }) = _UpdateTaskRequest;

  factory UpdateTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateTaskRequestFromJson(json);
}
