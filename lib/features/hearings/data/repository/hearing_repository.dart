import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/hearing.dart';
import '../../domain/repository/i_hearing_repository.dart';

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
    }
  }
}
