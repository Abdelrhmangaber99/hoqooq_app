import '../../../../core/network/api_result.dart';
import '../../data/models/create_event_request.dart';
import '../entities/calendar_event_entity.dart';
import '../entities/timeline_item.dart';

/// Mirrors API_CONTRACT.md finding I (Calendar) — read plus custom-event
/// create for M4. `GET /calendar/timeline` is the one endpoint anywhere in
/// the API with real server-side filtering; used directly rather than
/// fetching everything and filtering client-side.
///
/// `createEvent` mirrors `POST /calendar` exactly. Only `CUSTOM` events are
/// ever created through this app — `HEARING`/`TASK_DEADLINE` items on the
/// timeline are server-derived from real hearings/tasks, not user-created
/// calendar rows (see PLAN.md's M4 scope decision). No update/delete —
/// deferred across every module this milestone, not specific to Calendar.
abstract class ICalendarRepository {
  ApiResult<List<TimelineItem>> getTimeline({
    DateTime? startDate,
    DateTime? endDate,
    String? caseId,
    String? userId,
  });

  ApiResult<CalendarEventEntity> createEvent(CreateEventRequest request);
}
