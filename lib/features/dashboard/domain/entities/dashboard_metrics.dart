import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_metrics.freezed.dart';
part 'dashboard_metrics.g.dart';

/// Wire shape for `GET /reports/dashboard` (Reports module) per
/// API_CONTRACT.md finding I.
///
/// Deliberately **not** `GET /dashboard` (Dashboard module) — confirmed
/// with the user: that endpoint is the System/Super Admin's platform-wide
/// view (its service never scopes any count by tenant/user despite
/// receiving a `userId` param), not a per-tenant metric, and this
/// tenant-scoped mobile client never calls it. `GET /reports/dashboard` is
/// narrower (3 metrics, no `recentActivity`, no invoice counts) but
/// correctly user-scoped — every query joins on `team.userId`/
/// `assignedToId` to the current user.
@freezed
abstract class DashboardMetrics with _$DashboardMetrics {
  const factory DashboardMetrics({
    required int totalActiveCases,
    required int pendingTasks,
    required int upcomingHearings,
  }) = _DashboardMetrics;

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) =>
      _$DashboardMetricsFromJson(json);
}
