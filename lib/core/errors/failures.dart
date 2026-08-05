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
