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

/// 402 Payment Required. BR-031: v2 removed the old global
/// `SubscriptionGuard` that auto-blocked the whole workspace on an
/// inactive subscription — that guard, and this app's matching
/// `SessionSubscriptionInactive`/blocking-screen mechanism, are gone.
/// This typed failure only exists so a call site can still show a
/// meaningful message on the rare/unexpected 402, without reintroducing
/// any app-wide session-state side effect.
class SubscriptionInactiveFailure extends Failure {
  const SubscriptionInactiveFailure([
    super.message = 'Subscription inactive or expired',
  ]);
}
