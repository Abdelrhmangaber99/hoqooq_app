import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../authentication/presentation/bloc/session_cubit.dart';
import '../../domain/entities/case_team_member.dart';
import '../../domain/entities/legal_case.dart';
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
  CaseRepository(this._dio, this._sessionCubit);

  final Dio _dio;
  final SessionCubit _sessionCubit;

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
      final sessionState = _sessionCubit.state;
      final tenantId = sessionState is SessionAuthenticated
          ? sessionState.user.tenant?.id
          : null;
      final body = {
        ...request.toJson(),
        if (tenantId != null) 'tenantId': tenantId,
      };
      final response = await _dio.post('/cases', data: body);
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

  @override
  ApiResult<CaseTeamMember> assignTeamMember(
    String caseId,
    AssignCaseRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/cases/$caseId/assignments',
        data: request.toJson(),
      );
      return Right(
        CaseTeamMember.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
