import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/client_meeting.dart';
import '../../domain/repository/i_meeting_repository.dart';
import '../models/meeting_requests.dart';

@LazySingleton(as: IMeetingRepository)
class MeetingRepository implements IMeetingRepository {
  MeetingRepository(this._dio);
  final Dio _dio;

  @override
  ApiResult<List<ClientMeeting>> getMeetings() async {
    try {
      final response = await _dio.get('/meetings');
      return Right(
        (response.data as List<dynamic>)
            .map((item) => ClientMeeting.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (error) {
      return Left(mapDioError(error));
    } catch (_) {
      // A payload that doesn't match the entity shape must fail as an
      // `ApiResult`, never as a thrown exception: an uncaught decode error
      // escapes the calling bloc's event handler before it can emit, which
      // pins the screen on its loading spinner instead of showing an error.
      return const Left(ServerFailure());
    }
  }

  @override
  ApiResult<ClientMeeting> create(CreateMeetingRequest request) =>
      _write('/meetings', request.toJson(), post: true);

  @override
  ApiResult<ClientMeeting> update(String id, UpdateMeetingRequest request) =>
      _write('/meetings/$id', request.toJson());

  @override
  ApiResult<ClientMeeting> complete(String id, String outcomeNotes) =>
      _write('/meetings/$id/complete', {'outcomeNotes': outcomeNotes});

  ApiResult<ClientMeeting> _write(
    String path,
    Map<String, dynamic> data, {
    bool post = false,
  }) async {
    try {
      final response = post
          ? await _dio.post(path, data: data)
          : await _dio.patch(path, data: data);
      return Right(
        ClientMeeting.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (error) {
      return Left(mapDioError(error));
    }
  }

  @override
  ApiResult<void> cancel(String id) async {
    try {
      await _dio.delete('/meetings/$id');
      return const Right(null);
    } on DioException catch (error) {
      return Left(mapDioError(error));
    }
  }
}
