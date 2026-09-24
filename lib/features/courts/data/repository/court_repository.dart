import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../cases/domain/entities/court.dart';
import '../../domain/entities/court_circuit.dart';
import '../../domain/entities/case_type_reference.dart';
import '../../domain/entities/governorate.dart';
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
  ApiResult<List<CaseTypeReference>> getCaseTypes() async {
    try {
      final response = await _dio.get('/reference/case-types');
      final data = response.data as List<dynamic>;
      return Right(
        data
            .map(
              (json) => CaseTypeReference.fromJson(
                json as Map<String, dynamic>,
              ),
            )
            .toList(),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<List<Governorate>> getGovernorates() async {
    try {
      final response = await _dio.get('/reference/governorates');
      final data = response.data as List<dynamic>;
      return Right(
        data
            .map((json) => Governorate.fromJson(json as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<List<Court>> getCourts([String? governorateId]) async {
    if (governorateId == null) return const Right([]);
    try {
      final response = await _dio.get(
        '/reference/governorates/$governorateId/courts',
      );
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

  @override
  ApiResult<List<CourtCircuit>> getCircuits(String courtId) async {
    try {
      final response = await _dio.get('/reference/courts/$courtId/circuits');
      final data = response.data as List<dynamic>;
      return Right(
        data
            .map((json) => CourtCircuit.fromJson(json as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
