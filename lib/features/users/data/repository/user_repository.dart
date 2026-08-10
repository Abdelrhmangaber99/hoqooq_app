import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../authentication/presentation/bloc/session_cubit.dart';
import '../../domain/repository/i_user_repository.dart';

/// Real implementation of [IUserRepository] against `GET /users`.
///
/// The backend currently returns users from every tenant for this endpoint.
/// Filter at this single boundary so assignment pickers cannot surface staff
/// outside the signed-in firm. See API_CONTRACT.md finding Z.
@LazySingleton(as: IUserRepository)
class UserRepository implements IUserRepository {
  UserRepository(this._dio, this._sessionCubit);

  final Dio _dio;
  final SessionCubit _sessionCubit;

  @override
  ApiResult<List<User>> getUsers() async {
    try {
      final response = await _dio.get('/users');
      final data = response.data as List<dynamic>;
      final users = data
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
      final sessionState = _sessionCubit.state;
      final tenantId = sessionState is SessionAuthenticated
          ? sessionState.user.tenant?.id
          : null;

      // A tenant-less session (for example the platform SUPER_ADMIN) has no
      // safe tenant-scoped result set. Returning no staff is safer than
      // exposing platform-wide accounts.
      return Right(
        tenantId == null
            ? const <User>[]
            : users.where((user) => user.tenant?.id == tenantId).toList(),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
