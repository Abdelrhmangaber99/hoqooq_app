import 'package:json_annotation/json_annotation.dart';

/// `eventType` on `GET/PATCH /calendar` — confirmed from the real backend
/// entity (`src/modules/calendar/entities/calendar-event.entity.ts`), not
/// the standalone `enums/event-type.enum.ts` file (confirmed dead code,
/// zero importers — that file has `MEETING/DEADLINE/CUSTOM`, which does not
/// match the API).
enum CalendarEventType {
  @JsonValue('HEARING')
  hearing,
  @JsonValue('TASK_DEADLINE')
  taskDeadline,
  @JsonValue('CUSTOM')
  custom,
  @JsonValue('unknown')
  unknown,
}
