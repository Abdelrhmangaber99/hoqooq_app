import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/legal_case.dart';
import '../../domain/repository/i_case_repository.dart';
import '../models/update_case_request.dart';

/// Real implementation of [ICaseRepository] against `GET /cases` and
/// `GET /cases/{id}` per API_CONTRACT.md §8. Replaces MockCaseRepository —
/// no mock is left in the cases path. Read-only for M2.
@LazySingleton(as: ICaseRepository)
class CaseRepository implements ICaseRepository {
  CaseRepository(this._dio);

  final Dio _dio;

  @override
  ApiResult<List<LegalCase>> getCases() async {
    try {
      final response = await _dio.get('/cases');
      final data = response.data as List<dynamic>;
      return Right(
        data
            .map((json) => LegalCase.fromJson(json as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<LegalCase> getCaseDetails(String id) async {
    try {
      final response = await _dio.get('/cases/$id');
      return Right(LegalCase.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<LegalCase> updateCase(String id, UpdateCaseRequest request) async {
    try {
      final response = await _dio.patch('/cases/$id', data: request.toJson());
      return Right(LegalCase.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
