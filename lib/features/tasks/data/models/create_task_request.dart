import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_status.dart';

part 'create_task_request.freezed.dart';
part 'create_task_request.g.dart';

/// Request body for `POST /tasks` per `CreateTaskDto`
/// (`Hoqooq-main/src/modules/tasks/dtos/create-task.dto.ts`). No `Lookup`
/// dependency at all — `assignedById`/`assignedToId` reference the real,
/// browsable `User` entity (`GET /users`), not an unbrowsable `Lookup` row.
@freezed
abstract class CreateTaskRequest with _$CreateTaskRequest {
  const factory CreateTaskRequest({
    required String caseId,
    required String assignedToId,
    required String title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    String? linkedEntityType,
    String? linkedEntityId,
  }) = _CreateTaskRequest;

  factory CreateTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTaskRequestFromJson(json);
}
