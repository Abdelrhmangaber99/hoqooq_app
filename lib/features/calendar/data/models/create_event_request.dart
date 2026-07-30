import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/calendar_event_type.dart';

part 'create_event_request.freezed.dart';
part 'create_event_request.g.dart';

/// Request body for `POST /calendar` per `CreateEventDto`
/// (`Hoqooq-main/src/modules/calendar/dtos/create-event.dto.ts`).
///
/// `userId` is required by the DTO and is NOT overridden server-side
/// (`CalendarService.create` spreads `createDto` as-is, only adding
/// `tenantId` from the JWT) — unlike `tenantId`, there's no backend
/// derivation to lean on. `CalendarEventFormPage` always sets this to the
/// current user rather than exposing it as a field, since a personal
/// calendar event has no reason to be creatable on someone else's behalf
/// from this screen.
///
/// `eventType` is always [CalendarEventType.custom] here — `HEARING`/
/// `TASK_DEADLINE` events are how `/calendar/timeline` aggregates real
/// hearings/tasks server-side, not something a user creates directly (see
/// PLAN.md's M4 Calendar scope decision). `referenceId` is intentionally
/// omitted — it only makes sense for the two event types this form never
/// creates.
@freezed
abstract class CreateEventRequest with _$CreateEventRequest {
  const factory CreateEventRequest({
    required String userId,
    required String title,
    String? description,
    @Default(CalendarEventType.custom) CalendarEventType eventType,
    required DateTime startsAt,
    DateTime? endsAt,
    String? location,
    bool? isAllDay,
  }) = _CreateEventRequest;

  factory CreateEventRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateEventRequestFromJson(json);
}
