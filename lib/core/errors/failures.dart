import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized access']);
}

/// 403 Forbidden — the user is authenticated but lacks the permission this
/// action requires (BR-034: RBAC is enforced server-side; UI gating via
/// `User.hasPerm()` is UX-only and can't cover every path — e.g. a
/// permission revoked mid-session, or an action this milestone didn't get
/// around to gating yet). Distinct from `ServerFailure` so callers can
/// skip a "Retry" action that will just 403 again.
class ForbiddenFailure extends Failure {
  const ForbiddenFailure([
    super.message = 'You don\'t have permission to do this',
  ]);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// 402 Payment Required — `SubscriptionGuard` blocks the request because
/// the tenant's subscription isn't `ACTIVE`/unexpired. Confirmed
/// intentional by the backend team (API_CONTRACT.md finding M), not a bug
/// to route around. Callers generally don't need to handle this directly
/// — `SubscriptionInterceptor` already transitions `SessionCubit` to
/// `SessionSubscriptionInactive` before this reaches a repository, which
/// the app-wide blocking screen reacts to — but the typed failure still
/// exists for any repository call site that wants to distinguish it.
class SubscriptionInactiveFailure extends Failure {
  const SubscriptionInactiveFailure([
    super.message = 'Subscription inactive or expired',
  ]);
}
