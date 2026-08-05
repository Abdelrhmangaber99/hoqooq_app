import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../features/authentication/presentation/bloc/session_cubit.dart';

/// Handles BR-010/012's real mechanism: a global `SubscriptionGuard` on the
/// backend that 402s nearly every authenticated request (reads included)
/// for a tenant whose subscription isn't `ACTIVE`/unexpired — confirmed
/// intentional by the backend team (API_CONTRACT.md finding M), not
/// something to catch-and-ignore per call site.
///
/// On any 402, transitions `SessionCubit` to `SessionSubscriptionInactive`
/// — `AppRouter`'s redirect (driven by a `GoRouterRefreshStream` listening
/// to `SessionCubit`) reacts to that state change immediately and routes
/// to the app-wide blocking screen, regardless of which repository call
/// happened to trigger it. The error is still passed through
/// (`handler.next`) so the triggering call site's own `Failure` handling
/// (via `mapDioError`'s `SubscriptionInactiveFailure` branch) still runs
/// too, in case that screen wants to show something before the redirect
/// takes effect.
@injectable
class SubscriptionInterceptor extends Interceptor {
  SubscriptionInterceptor(this._sessionCubit);

  final SessionCubit _sessionCubit;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 402) {
      final data = err.response?.data;
      final message = data is Map<String, dynamic> && data['message'] is String
          ? data['message'] as String
          : 'Subscription inactive or expired';
      _sessionCubit.subscriptionInactive(message);
    }
    handler.next(err);
  }
}
