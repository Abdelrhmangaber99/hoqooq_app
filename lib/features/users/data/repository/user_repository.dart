import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../authentication/presentation/bloc/session_cubit.dart';
import '../../domain/repository/i_user_repository.dart';

/// Real implementation of [IUserRepository] against the deployed employee
/// directory. The live API intentionally has no platform-wide `GET /users`.
@LazySingleton(as: IUserRepository)
class UserRepository implements IUserRepository {
  UserRepository(this._dio, this._sessionCubit);

  final Dio _dio;
  final SessionCubit _sessionCubit;

  @override
  ApiResult<List<User>> getUsers() async {
    return getAssignableUsers();
  }

  @override
  ApiResult<List<User>> getAssignableUsers() async {
    final sessionState = _sessionCubit.state;
    if (sessionState is! SessionAuthenticated) return const Right([]);

    final currentUser = sessionState.user;
    // Platform admins have no tenant employee directory and cannot assign
    // tenant work. Avoid calling a non-existent platform-wide users route.
    if (currentUser.isSuperAdmin) return const Right([]);

    try {
      final response = await _dio.get('/employees');
      final rawData = response.data;
      final data = rawData is List
          ? rawData
          : (rawData is Map && rawData['data'] is List
              ? rawData['data'] as List<dynamic>
              : const <dynamic>[]);
      final fallbackDate = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      final users = data
          .map((row) {
            final json = row as Map<String, dynamic>;
            final nested = json['user'] is Map
                ? Map<String, dynamic>.from(json['user'] as Map)
                : const <String, dynamic>{};
            return User(
              id: (json['userId'] ?? nested['id'])?.toString() ?? '',
              email: nested['email']?.toString() ?? '',
              fullName: nested['fullName']?.toString() ?? '',
              status: 'ACTIVE',
              createdAt:
                  DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
                  fallbackDate,
              updatedAt:
                  DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
                  fallbackDate,
              accountType: 'EMPLOYEE',
              tenant: currentUser.tenant,
            );
          })
          .where((user) => user.id.isNotEmpty)
          .toList();

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
