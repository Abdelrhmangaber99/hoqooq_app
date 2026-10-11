import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
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
  ApiResult<AuthResponse?> activateAccount({
    required String token,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/activate',
        data: {'token': token, 'password': password},
      );
      if (response.data != null &&
          response.data is Map<String, dynamic> &&
          (response.data as Map<String, dynamic>).containsKey('accessToken')) {
        return Right(
          AuthResponse.fromJson(response.data as Map<String, dynamic>),
        );
      }
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

  @override
  ApiResult<User> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      // Blank values are omitted rather than sent as empty strings. The
      // backend validates `avatarUrl` as a URL, so sending `''` made the whole
      // save fail with a validation error whenever the avatar field was left
      // empty — including for every user who has no photo yet.
      final data = <String, dynamic>{
        if (fullName != null && fullName.trim().isNotEmpty)
          'fullName': fullName,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone,
        if (avatarUrl != null && avatarUrl.trim().isNotEmpty)
          'avatarUrl': avatarUrl,
      };
      final response = await _patchProfile(data);
      return Right(User.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  /// The deployed API exposes profile editing only at `PATCH /users/me`.
  Future<Response<dynamic>> _patchProfile(Map<String, dynamic> data) async {
    return _dio.patch('/users/me', data: data);
  }
}
