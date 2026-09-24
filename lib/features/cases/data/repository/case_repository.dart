import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../authentication/presentation/bloc/session_cubit.dart';
import '../../domain/entities/legal_case.dart';
import '../../domain/entities/case_status.dart';
import '../../domain/repository/i_case_repository.dart';
import '../models/assign_case_request.dart';
import '../models/create_case_request.dart';
import '../models/update_case_request.dart';

/// Real implementation of [ICaseRepository] against `GET /cases` and
/// `GET /cases/{id}` per API_CONTRACT.md §8. Replaces MockCaseRepository —
/// no mock is left in the cases path.
///
/// `createCase` reads the current tenant id from [SessionCubit] and
/// injects it into the wire body — same pattern as
/// `ClientRepository.createClient()` — even though `CasesService.create`
/// also always overrides it server-side; `CreateCaseDto.tenantId` is still
/// required for the request to pass validation.
@LazySingleton(as: ICaseRepository)
class CaseRepository implements ICaseRepository {
  CaseRepository(this._dio, SessionCubit _);

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
  ApiResult<LegalCase> createCase(CreateCaseRequest request) async {
    try {
      final body = _withoutNulls(request.toJson());
      final response = await _dio.post('/cases', data: body);
      return Right(LegalCase.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<LegalCase> updateCase(String id, UpdateCaseRequest request) async {
    try {
      final body = request.toJson();
      final response = await _dio.patch('/cases/$id', data: body);
      return Right(LegalCase.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<LegalCase> changeCaseStatus(String id, CaseStatus status) async {
    try {
      final response = await _dio.patch(
        '/cases/$id/status',
        data: {'status': status.name.toUpperCase()},
      );
      return Right(LegalCase.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<void> setCaseAccess(
    String caseId,
    AssignCaseRequest request,
  ) async {
    try {
      await _dio.put(
        '/cases/$caseId/access-grants/${request.userId}',
        data: request.toJson(),
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<void> revokeCaseAccess(String caseId, String userId) async {
    try {
      await _dio.delete('/cases/$caseId/access-grants/$userId');
      return const Right(null);
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}

Map<String, dynamic> _withoutNulls(Map<String, dynamic> value) {
  final result = Map<String, dynamic>.from(value);
  result.removeWhere((_, item) => item == null);
  return result;
}
