import 'package:json_annotation/json_annotation.dart';

/// `priority` on `GET/PATCH /tasks` — confirmed from the real backend
/// entity (`src/modules/tasks/entities/task.entity.ts`), not the standalone
/// `enums/task-priority.enum.ts` file (confirmed dead code, zero importers —
/// that file uses `MEDIUM` instead of `NORMAL`, which does not match the
/// API).
enum TaskPriority {
  @JsonValue('LOW')
  low,
  @JsonValue('MEDIUM')
  normal,
  @JsonValue('HIGH')
  high,
  @JsonValue('URGENT')
  urgent,
  @JsonValue('unknown')
  unknown,
}
