import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../domain/repository/i_user_repository.dart';

/// Real implementation of [IUserRepository] against `GET /users`.
@LazySingleton(as: IUserRepository)
class UserRepository implements IUserRepository {
  UserRepository(this._dio);

  final Dio _dio;

  @override
  ApiResult<List<User>> getUsers() async {
    try {
      final response = await _dio.get('/users');
      final data = response.data as List<dynamic>;
      return Right(
        data
            .map((json) => User.fromJson(json as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
