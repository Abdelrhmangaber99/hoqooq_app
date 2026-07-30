import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/my_firm.dart';
import '../../domain/entities/user.dart';
import '../../domain/repository/i_auth_repository.dart';
import '../models/auth_response.dart';
import '../models/change_password_request.dart';
import '../models/forgot_password_request.dart';
import '../models/login_request.dart';
import '../models/refresh_request.dart';
import '../models/reset_password_request.dart';

/// Real implementation of [IAuthRepository] against the endpoints
/// documented in API_CONTRACT.md §1-2. Replaces the earlier
/// MockAuthRepository — no mock is left in the auth path.
@LazySingleton(as: IAuthRepository)
class AuthRepository implements IAuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  @override
  ApiResult<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _dio.post('/auth/login', data: request.toJson());
      return Right(
        AuthResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<AuthResponse> refresh({required String refreshToken}) async {
    try {
      final request = RefreshRequest(refreshToken: refreshToken);
      final response = await _dio.post('/auth/refresh', data: request.toJson());
      return Right(
        AuthResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<void> logout({required String refreshToken}) async {
    try {
      await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
      return const Right(null);
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<User> getCurrentUser() async {
    try {
      final response = await _dio.get('/users/me');
      return Right(User.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<MyFirm> getMyFirm() async {
    try {
      final response = await _dio.get('/tenants/my-firm');
      return Right(MyFirm.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<void> forgotPassword({required String email}) async {
    try {
      final request = ForgotPasswordRequest(email: email);
      await _dio.post('/auth/forgot-password', data: request.toJson());
      return const Right(null);
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final request = ResetPasswordRequest(
        token: token,
        newPassword: newPassword,
      );
      await _dio.post('/auth/reset-password', data: request.toJson());
      return const Right(null);
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final request = ChangePasswordRequest(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      await _dio.post('/auth/change-password', data: request.toJson());
      return const Right(null);
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
