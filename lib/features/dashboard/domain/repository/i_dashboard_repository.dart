import '../../../../core/network/api_result.dart';
import '../entities/dashboard_metrics.dart';

/// Mirrors API_CONTRACT.md finding I (Dashboard) — read-only for M3.
/// `GET /reports/dashboard`, not `GET /dashboard` (see [DashboardMetrics]'s
/// doc comment for why).
abstract class IDashboardRepository {
  ApiResult<DashboardMetrics> getMetrics();
}
