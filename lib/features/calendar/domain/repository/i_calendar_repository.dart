import '../../../../core/network/api_result.dart';
import '../entities/timeline_item.dart';

/// Mirrors API_CONTRACT.md finding I (Calendar) — read-only for M3.
/// `GET /calendar/timeline` is the one endpoint anywhere in the API with
/// real server-side filtering; used directly rather than fetching
/// everything and filtering client-side.
abstract class ICalendarRepository {
  ApiResult<List<TimelineItem>> getTimeline({
    DateTime? startDate,
    DateTime? endDate,
    String? caseId,
    String? userId,
  });
}
