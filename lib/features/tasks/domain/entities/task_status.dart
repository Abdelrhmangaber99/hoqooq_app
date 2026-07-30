import 'package:json_annotation/json_annotation.dart';

/// `status` on `GET/PATCH /tasks` — confirmed from the real backend entity
/// (`src/modules/tasks/entities/task.entity.ts`), not the standalone
/// `enums/task-status.enum.ts` file (confirmed dead code, zero importers —
/// that file has `TODO/IN_PROGRESS/DONE`, which does not match the API).
enum TaskStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('IN_PROGRESS')
  inProgress,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('unknown')
  unknown,
}
