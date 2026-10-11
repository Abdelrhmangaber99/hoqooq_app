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
      _$TaskItemFromJson(_normalizeTaskJson(json));
}

/// The deployed payload types `caseId`/`description`/`dueDate`/`completedAt`
/// loosely — `caseId` arrives as the nested Case object rather than a string
/// — and its vocabulary differs from this app's enums (`TODO` vs `NEW`,
/// `MEDIUM` vs `NORMAL`). One unexpected shape must not escape
/// `TaskItem.fromJson`: that exception bypasses the repository's
/// `on DioException` catch, kills the fetch handler before it can emit, and
/// leaves Tasks (and the Case Details tasks tab) spinning forever.
Map<String, dynamic> _normalizeTaskJson(Map<String, dynamic> json) {
  final rawCase =
      json['case'] ?? (json['caseId'] is Map ? json['caseId'] : null);
  final nestedCase = rawCase is Map ? Map<String, dynamic>.from(rawCase) : null;
  const epoch = '1970-01-01T00:00:00.000Z';
  return {
    ...json,
    'caseId': _taskId(json['caseId']) ?? _nestedId(nestedCase),
    'assignedById':
        _taskId(json['assignedById']) ?? _nestedId(json['assignedBy']) ?? '',
    'assignedToId':
        _taskId(json['assignedToId']) ?? _nestedId(json['assignedTo']) ?? '',
    'assignedBy': _normalizeCompactUser(json['assignedBy']),
    'assignedTo': _normalizeCompactUser(json['assignedTo']),
    'title': json['title']?.toString() ?? '',
    'description': json['description'] is String ? json['description'] : null,
    'dueDate': json['dueDate'] is String ? json['dueDate'] : null,
    'completedAt': json['completedAt'] is String ? json['completedAt'] : null,
    'status': json['status'] ?? 'unknown',
    'priority': json['priority'] ?? 'unknown',
    'case': nestedCase,
    'createdAt': json['createdAt'] is String ? json['createdAt'] : epoch,
    'updatedAt': json['updatedAt'] is String ? json['updatedAt'] : epoch,
  };
}

String? _taskId(Object? value) =>
    value is String && value.isNotEmpty ? value : null;

String? _nestedId(Object? value) => value is Map ? _taskId(value['id']) : null;

Map<String, dynamic>? _normalizeCompactUser(Object? value) {
  if (value is! Map) return null;
  final user = Map<String, dynamic>.from(value);
  const epoch = '1970-01-01T00:00:00.000Z';
  user
    ..putIfAbsent('id', () => '')
    ..putIfAbsent('email', () => '')
    ..putIfAbsent('fullName', () => '')
    ..putIfAbsent('status', () => 'ACTIVE')
    ..putIfAbsent('createdAt', () => epoch)
    ..putIfAbsent('updatedAt', () => epoch);
  return user;
}
