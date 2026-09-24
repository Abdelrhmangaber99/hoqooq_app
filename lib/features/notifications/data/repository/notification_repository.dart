import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/daily_activity_item.dart';
import '../../domain/repository/i_notification_repository.dart';

/// Real implementation of [INotificationRepository] against
/// `/notifications/*` per API_CONTRACT.md finding S. Replaces the 100%-
/// hardcoded mock content `NotificationsPage` used since before M1 — no
/// mock/bloc ever existed for this feature until now.
@LazySingleton(as: INotificationRepository)
class NotificationRepository implements INotificationRepository {
  NotificationRepository(this._dio);

  final Dio _dio;

  @override
  ApiResult<List<AppNotification>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications/me');
      final data = response.data as List<dynamic>;
      return Right(
        data
            .map(
              (json) => AppNotification.fromJson(json as Map<String, dynamic>),
            )
            .toList(),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<AppNotification> markAsRead(String id) async {
    try {
      final response = await _dio.patch('/notifications/$id/read');
      return Right(
        AppNotification.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<List<DailyActivityItem>> getDailyFeed(DateTime date) async {
    try {
      final dateValue =
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
      final response = await _dio.get(
        '/notifications/daily',
        queryParameters: {'date': dateValue},
      );
      return Right(
        (response.data as List<dynamic>)
            .map(
              (json) =>
                  DailyActivityItem.fromJson(json as Map<String, dynamic>),
            )
            .toList(),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
