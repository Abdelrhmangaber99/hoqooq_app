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

  @override
  ApiResult<List<User>> getAssignableUsers() async {
    final sessionState = _sessionCubit.state;
    if (sessionState is! SessionAuthenticated) return const Right([]);

    final currentUser = sessionState.user;
    if (currentUser.isSuperAdmin) return getUsers();

    try {
      final response = await _dio.get('/employees');
      final data = response.data as List<dynamic>;
      final fallbackDate = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      final users = data.map((row) {
        final json = row as Map<String, dynamic>;
        final nested = json['user'] is Map
            ? Map<String, dynamic>.from(json['user'] as Map)
            : const <String, dynamic>{};
        return User(
          id: (json['userId'] ?? nested['id'])?.toString() ?? '',
          email: nested['email']?.toString() ?? '',
          fullName: nested['fullName']?.toString() ?? '',
          isSuperAdmin: false,
          status: 'ACTIVE',
          mfaEnabled: false,
          createdAt:
              DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
              fallbackDate,
          updatedAt:
              DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
              fallbackDate,
          accountType: 'EMPLOYEE',
          tenant: currentUser.tenant,
        );
      }).where((user) => user.id.isNotEmpty).toList();

      if (!users.any((user) => user.id == currentUser.id)) {
        users.insert(0, currentUser);
      }
      return Right(users);
    } on DioException catch (e) {
      if (currentUser.isActive) return Right([currentUser]);
      return Left(mapDioError(e));
    }
  }
}
