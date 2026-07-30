import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../cases/domain/entities/court.dart';
import '../../domain/repository/i_court_repository.dart';

/// Real implementation of [ICourtRepository] against `GET /courts`.
/// Confirmed (unlike most of this API) to actually apply
/// `plainToInstance(CourtResponseDto, ...)` server-side — the response
/// shape is enforced, not just documented.
@LazySingleton(as: ICourtRepository)
class CourtRepository implements ICourtRepository {
  CourtRepository(this._dio);

  final Dio _dio;

  @override
  ApiResult<List<Court>> getCourts() async {
    try {
      final response = await _dio.get('/courts');
      final data = response.data as List<dynamic>;
      return Right(
        data
            .map((json) => Court.fromJson(json as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
