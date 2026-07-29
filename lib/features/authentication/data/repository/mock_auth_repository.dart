import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/auth/user_role.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repository/i_auth_repository.dart';

@LazySingleton(as: IAuthRepository)
class MockAuthRepository implements IAuthRepository {
  User? _currentUser;

  @override
  ApiResult<User> login({required String email, required String password}) async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (email == 'youssefusama@gmail.com' && password == '12345678') {
      _currentUser = const User(
        id: '1',
        fullName: 'James Reynolds',
        email: 'youssefusama@gmail.com',
        role: UserRole.firmOwner,
        lawFirmName: 'Reynolds & Associates',
        tenantId: 'tenant_123',
      );
      return Right(_currentUser!);
    } else {
      return const Left(UnauthorizedFailure('Invalid email or password'));
    }
  }

  @override
  ApiResult<User> register({
    required String fullName,
    required String email,
    required String lawFirmName,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    _currentUser = User(
      id: '2',
      fullName: fullName,
      email: email,
      role: UserRole.firmOwner,
      lawFirmName: lawFirmName,
      tenantId: 'new_tenant',
    );
    return Right(_currentUser!);
  }

  @override
  ApiResult<void> logout() async {
    _currentUser = null;
    return const Right(null);
  }

  @override
  ApiResult<User?> getCurrentUser() async {
    return Right(_currentUser);
  }

  @override
  ApiResult<void> forgotPassword(String email) async {
    return const Right(null);
  }
}
