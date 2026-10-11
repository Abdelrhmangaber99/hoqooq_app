import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/hearing.dart';
import '../../domain/repository/i_hearing_repository.dart';
import '../models/complete_hearing_request.dart';
import '../models/create_hearing_request.dart';
import '../models/update_hearing_request.dart';

/// Real implementation of [IHearingRepository] against `GET /hearings`.
@LazySingleton(as: IHearingRepository)
class HearingRepository implements IHearingRepository {
  HearingRepository(this._dio);

  final Dio _dio;

  @override
  ApiResult<List<Hearing>> getHearings() async {
    try {
      final response = await _dio.get('/hearings');
      final data = response.data as List<dynamic>;
      return Right(
        data
            .map((json) => Hearing.fromJson(json as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    } catch (_) {
      // A payload that doesn't match the entity shape must fail as an
      // `ApiResult`, never as a thrown exception: an uncaught decode error
      // escapes the calling bloc's event handler before it can emit, which
      // pins the screen on its loading spinner instead of showing an error.
      return const Left(ServerFailure());
    }
  }

  @override
  ApiResult<Hearing> createHearing(CreateHearingRequest request) async {
    try {
      final response = await _dio.post('/hearings', data: request.toJson());
      return Right(Hearing.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<Hearing> updateHearing(
    String id,
    UpdateHearingRequest request,
  ) async {
    try {
      final response = await _dio.patch(
        '/hearings/$id',
        data: request.toJson(),
      );
      return Right(Hearing.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<Hearing> completeHearing(
    String id,
    CompleteHearingRequest request,
  ) async {
    try {
      final response = await _dio.patch(
        '/hearings/$id/complete',
        data: request.toJson(),
      );
      return Right(Hearing.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
