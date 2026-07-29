import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../data/models/auth_response.dart';
import '../repository/i_auth_repository.dart';

@lazySingleton
class LoginUseCase {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  ApiResult<AuthResponse> execute({
    required String email,
    required String password,
  }) {
    return repository.login(email: email, password: password);
  }
}
