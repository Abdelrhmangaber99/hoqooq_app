import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/calendar_event_entity.dart';
import '../../domain/entities/timeline_item.dart';
import '../../domain/repository/i_calendar_repository.dart';
import '../models/create_event_request.dart';

/// Real implementation of [ICalendarRepository] against
/// `GET /calendar/timeline` and `POST /calendar`. Replaces
/// `MockAppointmentRepository` — no mock is left in the calendar path.
@LazySingleton(as: ICalendarRepository)
class CalendarRepository implements ICalendarRepository {
  CalendarRepository(this._dio);

  final Dio _dio;

  @override
  ApiResult<List<TimelineItem>> getTimeline({
    DateTime? startDate,
    DateTime? endDate,
    String? caseId,
  }) async {
    try {
      final response = await _dio.get(
        '/calendar/timeline',
        queryParameters: {
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
          if (caseId != null) 'caseId': caseId,
        },
      );
      final data = response.data as List<dynamic>;
      return Right(
        data
            .map((json) => TimelineItem.fromJson(json as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<CalendarEventEntity> createEvent(CreateEventRequest request) async {
    try {
      final response = await _dio.post('/calendar', data: request.toJson());
      return Right(
        CalendarEventEntity.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
