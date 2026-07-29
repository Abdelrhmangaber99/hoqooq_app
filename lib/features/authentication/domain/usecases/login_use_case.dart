import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../entities/user.dart';
import '../repository/i_auth_repository.dart';

@lazySingleton
class LoginUseCase {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  ApiResult<User> execute({
    required String email,
    required String password,
  }) {
    // Basic validation can happen here or in the Repository
    if (email.isEmpty || !email.contains('@')) {
      // return Left(ValidationFailure('Invalid email format')); 
      // Need to import dartz and failures to return Left directly if needed
    }
    return repository.login(email: email, password: password);
  }
}
