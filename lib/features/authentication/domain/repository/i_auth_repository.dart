import '../../../../core/network/api_result.dart';
import '../entities/user.dart';

abstract class IAuthRepository {
  ApiResult<User> login({
    required String email,
    required String password,
  });

  ApiResult<User> register({
    required String fullName,
    required String email,
    required String lawFirmName,
    required String password,
  });

  ApiResult<void> logout();

  ApiResult<User?> getCurrentUser();
  
  ApiResult<void> forgotPassword(String email);
}
