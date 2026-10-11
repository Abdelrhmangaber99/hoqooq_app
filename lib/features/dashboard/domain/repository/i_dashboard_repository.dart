import '../../../../core/network/api_result.dart';
import '../entities/dashboard_metrics.dart';

/// `GET /dashboard` — the tenant-scoped summary used by the reference web
/// Dashboard (see [DashboardRepository]'s doc comment). It is the only
/// dashboard endpoint that carries the firm's real total-case count; the
/// Reports module's `/reports/dashboard` omits it.
abstract class IDashboardRepository {
  ApiResult<DashboardMetrics> getMetrics();
}
