import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../cases/domain/entities/case_summary.dart';
import 'task_priority.dart';
import 'task_status.dart';

part 'task_item.freezed.dart';
part 'task_item.g.dart';

/// Wire shape for `GET/PATCH /tasks` per API_CONTRACT.md finding I.
///
/// Named `TaskItem`, not `Task`, same reasoning as `LegalCase` vs `case` —
/// avoids ambiguity with `dart:async`'s task-adjacent naming. `TasksController`
/// never applies `plainToInstance`/`ClassSerializerInterceptor` — the real
/// response is the raw entity as loaded by `TasksService`'s
/// `relations: ['case', 'assignedTo', 'assignedBy']`, so all three are
/// nested here (not the ID-only shape the unenforced `TaskResponseDto`
/// documents).
@freezed
abstract class TaskItem with _$TaskItem {
  const factory TaskItem({
    required String id,
    String? caseId,
    @JsonKey(name: 'case') CaseSummary? caseSummary,
    required String assignedById,
    User? assignedBy,
    required String assignedToId,
    User? assignedTo,
    required String title,
    String? description,
    @JsonKey(unknownEnumValue: TaskPriority.unknown)
    required TaskPriority priority,
    @JsonKey(unknownEnumValue: TaskStatus.unknown) required TaskStatus status,
    DateTime? dueDate,
    DateTime? completedAt,
    String? linkedEntityType,
    String? linkedEntityId,
    String? completionNote,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TaskItem;

  factory TaskItem.fromJson(Map<String, dynamic> json) =>
      _$TaskItemFromJson(json);
}
