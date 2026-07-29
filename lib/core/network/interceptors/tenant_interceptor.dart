import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../features/authentication/domain/repository/i_auth_repository.dart';
import '../../../di/injection.dart';

@injectable
class TenantInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // In a real app, we'd get the current user's tenant ID from a session/storage
    // For now, we simulate pulling it from the AuthRepository or a dedicated Tenant Service
    final authRepo = getIt<IAuthRepository>();
    final userResult = await authRepo.getCurrentUser();
    
    userResult.fold(
      (_) => null,
      (user) {
        if (user != null && user.tenantId != null) {
          options.headers['X-Tenant-ID'] = user.tenantId;
          options.headers['X-Workspace-Context'] = 'default';
        }
      },
    );

    super.onRequest(options, handler);
  }
}
