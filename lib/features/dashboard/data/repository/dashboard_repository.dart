import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/dashboard_metrics.dart';
import '../../domain/repository/i_dashboard_repository.dart';

/// Real implementation of [IDashboardRepository] against `GET /dashboard`.
///
/// `GET /dashboard` (`DashboardController` / `DashboardSummaryDto`) is the
/// tenant-scoped summary — `{totalCases, activeCases, pendingTasks,
/// upcomingHearings, recentActivity[]}` — and is exactly what the reference
/// web Dashboard calls (`dashboardApi.summary()`). The Reports module's
/// `GET /reports/dashboard` returns a narrower
/// `{totalActiveCases, pendingTasks, upcomingHearings}` with **no total-case
/// count**, which is why the KPI card fell back to the active count instead of
/// the firm's real totals. `DashboardService.getSummary` scopes every query by
/// `user.tenantId` (and, for an `EMPLOYEE`, by their case access grants), so
/// this is a per-tenant view, not the platform-wide one an older API-contract
/// note described.
@LazySingleton(as: IDashboardRepository)
class DashboardRepository implements IDashboardRepository {
  DashboardRepository(this._dio);

  final Dio _dio;

  @override
  ApiResult<DashboardMetrics> getMetrics() async {
    try {
      final response = await _dio.get('/dashboard');
      return Right(
        DashboardMetrics.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
