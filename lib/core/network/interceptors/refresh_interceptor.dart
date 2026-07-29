import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../../features/authentication/data/models/auth_response.dart';
import '../../../features/authentication/presentation/bloc/session_cubit.dart';
import '../../storage/token_storage.dart';
import '../api_config.dart';

/// Handles BR-033 refresh-token rotation. On a 401: calls `POST
/// /auth/refresh` once (via a plain, interceptor-free Dio so this can't
/// recurse into itself), rotates the stored refresh token, and retries the
/// original request with the new access token. On refresh failure, clears
/// the session so route guards redirect to login on the next navigation.
@injectable
class RefreshInterceptor extends Interceptor {
  RefreshInterceptor(this._tokenStorage, this._sessionCubit)
    : _rawDio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  /// Test-only seam: lets tests substitute a mock Dio for the internal raw
  /// client instead of hitting real network. Not used by injectable (it
  /// always resolves the unnamed constructor above).
  @visibleForTesting
  RefreshInterceptor.withDio(this._tokenStorage, this._sessionCubit, this._rawDio);

  final TokenStorage _tokenStorage;
  final SessionCubit _sessionCubit;
  final Dio _rawDio;

  Future<String?>? _refreshing;

  static const _retriedKey = 'hoqooq_refresh_retried';

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final alreadyRetried = err.requestOptions.extra[_retriedKey] == true;

    if (err.response?.statusCode != 401 || alreadyRetried) {
      handler.next(err);
      return;
    }

    final newAccessToken = await _refreshAccessToken();
    if (newAccessToken == null) {
      handler.next(err);
      return;
    }

    try {
      final retryOptions = err.requestOptions;
      retryOptions.extra[_retriedKey] = true;
      retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final retryResponse = await _rawDio.fetch(retryOptions);
      handler.resolve(retryResponse);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  /// Coalesces concurrent 401s (e.g. several in-flight requests when the
  /// access token expires) into a single refresh call.
  Future<String?> _refreshAccessToken() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<String?> _doRefresh() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) {
      _sessionCubit.unauthenticated();
      return null;
    }

    try {
      final response = await _rawDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final auth = AuthResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _tokenStorage.saveRefreshToken(auth.refreshToken);
      _sessionCubit.updateAccessToken(auth.accessToken);
      return auth.accessToken;
    } on DioException {
      await _tokenStorage.clear();
      _sessionCubit.unauthenticated();
      return null;
    }
  }
}
