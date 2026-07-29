import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../features/authentication/presentation/bloc/session_cubit.dart';

/// Attaches the in-memory access token (BR-033) to every request. Does not
/// send any tenant identifier — the backend derives tenant scope from the
/// JWT alone (BR-003); see CLAUDE.md for why the previous TenantInterceptor
/// was removed.
@injectable
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._sessionCubit);

  final SessionCubit _sessionCubit;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _sessionCubit.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
