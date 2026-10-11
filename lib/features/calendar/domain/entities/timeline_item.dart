import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../cases/domain/entities/case_summary.dart';
import '../../../hearings/domain/entities/hearing_status.dart';
import '../../../meetings/domain/entities/meeting_status.dart';
import '../../../service_of_process/domain/entities/service_status.dart';
import '../../../tasks/domain/entities/task_priority.dart';
import '../../../tasks/domain/entities/task_status.dart';
import 'calendar_event_type.dart';

part 'timeline_item.freezed.dart';

/// `GET /calendar/timeline` per API_CONTRACT.md finding I — the one
/// endpoint anywhere in the API with real server-side filtering
/// (`startDate`/`endDate`/`caseId`/`userId`). `CalendarService.getTimeline`
/// hand-builds a merged, loosely-typed (`any[]`) array from three different
/// sources sharing only `id`/`itemType`/`title`/`date` — not a single
/// entity or DTO, so this is parsed manually rather than via
/// `json_serializable`. Note the `userId` query param only restricts the
/// `CALENDAR_EVENT` portion — it does NOT filter the `HEARING`/`TASK`
/// portions (confirmed via an explicit comment in `calendar.service.ts`
/// acknowledging this), so don't rely on it for user-scoping tasks/hearings.
@freezed
sealed class TimelineItem with _$TimelineItem {
  const factory TimelineItem.event({
    required String id,
    required String title,
    required DateTime date,
    DateTime? endDate,
    @JsonKey(unknownEnumValue: CalendarEventType.unknown)
    required CalendarEventType eventType,
    String? referenceId,
  }) = TimelineEventItem;

  const factory TimelineItem.hearing({
    required String id,
    required String title,
    DateTime? date,
    @JsonKey(unknownEnumValue: HearingStatus.unknown)
    required HearingStatus status,
    CaseSummary? caseSummary,
    String? caseId,
  }) = TimelineHearingItem;

  const factory TimelineItem.service({
    required String id,
    required String title,
    DateTime? date,
    @JsonKey(unknownEnumValue: ServiceStatus.unknown)
    required ServiceStatus status,
    String? caseId,
  }) = TimelineServiceItem;

  const factory TimelineItem.meeting({
    required String id,
    required String title,
    DateTime? date,
    @JsonKey(unknownEnumValue: MeetingStatus.unknown)
    required MeetingStatus status,
    String? caseId,
  }) = TimelineMeetingItem;

  const factory TimelineItem.task({
    required String id,
    required String title,
    DateTime? date,
    @JsonKey(unknownEnumValue: TaskStatus.unknown) required TaskStatus status,
    @JsonKey(unknownEnumValue: TaskPriority.unknown)
    required TaskPriority priority,
    CaseSummary? caseSummary,
    String? caseId,
  }) = TimelineTaskItem;

  const factory TimelineItem.unknown({required String id, String? title}) =
      TimelineUnknownItem;

  factory TimelineItem.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final title = json['title'] as String?;
    final dateRaw = (json['startsAt'] ?? json['date']) as String?;
    final date = dateRaw != null ? DateTime.parse(dateRaw) : null;
    final type = (json['type'] ?? json['itemType']) as String?;

    switch (type) {
      case 'CUSTOM':
      case 'CALENDAR_EVENT':
        if (date == null) return TimelineItem.unknown(id: id, title: title);
        final endDateRaw = (json['endsAt'] ?? json['endDate']) as String?;
        return TimelineItem.event(
          id: id,
          title: title ?? '',
          date: date,
          endDate: endDateRaw != null ? DateTime.parse(endDateRaw) : null,
          eventType: _parseEventType(
            (json['eventType'] ?? json['type']) as String?,
          ),
          referenceId: json['referenceId'] as String?,
        );
      case 'HEARING':
        return TimelineItem.hearing(
          id: id,
          title: title ?? '',
          date: date,
          status: _parseHearingStatus(json['status'] as String?),
          caseSummary: _parseCaseSummary(json['case']),
          caseId: json['caseId'] as String?,
        );
      case 'SERVICE':
        return TimelineItem.service(
          id: id,
          title: title ?? 'Service of Process',
          date: date,
          status: _parseServiceStatus(json['status'] as String?),
          caseId: json['caseId'] as String?,
        );
      case 'MEETING':
        return TimelineItem.meeting(
          id: id,
          title: title ?? 'Client Meeting',
          date: date,
          status: _parseMeetingStatus(json['status'] as String?),
          caseId: json['caseId'] as String?,
        );
      case 'TASK':
        return TimelineItem.task(
          id: id,
          title: title ?? '',
          date: date,
          status: _parseTaskStatus(json['status'] as String?),
          priority: _parseTaskPriority(json['priority'] as String?),
          caseSummary: _parseCaseSummary(json['case']),
          caseId: json['caseId'] as String?,
        );
      default:
        return TimelineItem.unknown(id: id, title: title);
    }
  }
}

ServiceStatus _parseServiceStatus(String? value) => switch (value) {
  'SCHEDULED' => ServiceStatus.scheduled,
  'COMPLETED' => ServiceStatus.completed,
  'FAILED' => ServiceStatus.failed,
  'RESCHEDULED' => ServiceStatus.rescheduled,
  'CANCELLED' => ServiceStatus.cancelled,
  _ => ServiceStatus.unknown,
};

MeetingStatus _parseMeetingStatus(String? value) => switch (value) {
  'SCHEDULED' => MeetingStatus.scheduled,
  'COMPLETED' => MeetingStatus.completed,
  'CANCELLED' => MeetingStatus.cancelled,
  'RESCHEDULED' => MeetingStatus.rescheduled,
  _ => MeetingStatus.unknown,
};

CaseSummary? _parseCaseSummary(dynamic json) {
  if (json is! Map<String, dynamic>) return null;
  try {
    return CaseSummary.fromJson(json);
  } catch (_) {
    return null;
  }
}

CalendarEventType _parseEventType(String? value) => switch (value) {
  'HEARING' => CalendarEventType.hearing,
  'TASK_DEADLINE' => CalendarEventType.taskDeadline,
  'CUSTOM' => CalendarEventType.custom,
  _ => CalendarEventType.unknown,
};

HearingStatus _parseHearingStatus(String? value) => switch (value) {
  'SCHEDULED' => HearingStatus.scheduled,
  'COMPLETED' => HearingStatus.completed,
  'POSTPONED' => HearingStatus.adjourned,
  'MISSED' => HearingStatus.missed,
  'CANCELLED' => HearingStatus.cancelled,
  _ => HearingStatus.unknown,
};

TaskStatus _parseTaskStatus(String? value) => switch (value) {
  'TODO' => TaskStatus.newTask,
  'IN_PROGRESS' => TaskStatus.inProgress,
  'WAITING' => TaskStatus.waiting,
  'COMPLETED' => TaskStatus.completed,
  'CANCELLED' => TaskStatus.cancelled,
  _ => TaskStatus.unknown,
};

TaskPriority _parseTaskPriority(String? value) => switch (value) {
  'LOW' => TaskPriority.low,
  'MEDIUM' => TaskPriority.normal,
  'HIGH' => TaskPriority.high,
  'URGENT' => TaskPriority.urgent,
  _ => TaskPriority.unknown,
};
