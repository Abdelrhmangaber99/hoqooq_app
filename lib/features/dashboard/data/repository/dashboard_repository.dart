import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/dashboard_metrics.dart';
import '../../domain/repository/i_dashboard_repository.dart';

/// Real implementation of [IDashboardRepository] against
/// `GET /reports/dashboard`.
@LazySingleton(as: IDashboardRepository)
class DashboardRepository implements IDashboardRepository {
  DashboardRepository(this._dio);

  final Dio _dio;

  @override
  ApiResult<DashboardMetrics> getMetrics() async {
    try {
      final response = await _dio.get('/reports/dashboard');
      return Right(
        DashboardMetrics.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
