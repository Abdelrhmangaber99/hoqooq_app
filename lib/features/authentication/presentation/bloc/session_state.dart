part of 'session_cubit.dart';

abstract class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

/// App just started; we haven't checked stored credentials yet.
class SessionUnknown extends SessionState {
  const SessionUnknown();
}

class SessionAuthenticated extends SessionState {
  final User user;

  /// BR-005: true iff this user holds the `FIRM_ADMIN` role. See
  /// `User.isFirmAdmin`'s doc comment for how this is derived.
  final bool isFirmAdmin;

  const SessionAuthenticated(this.user, {required this.isFirmAdmin});

  @override
  List<Object?> get props => [user, isFirmAdmin];
}

class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated();
}

/// BR-010/012: entered when any request 402s — `SubscriptionGuard` blocks
/// nearly every authenticated call (reads included, not just writes) for a
/// tenant whose subscription isn't `ACTIVE`/unexpired, confirmed
/// intentional by the backend team (API_CONTRACT.md finding M). This is
/// deliberately a distinct state from `SessionUnauthenticated` — the
/// user's identity/token are still valid, this isn't a logout, just a
/// gate. The access token stays in memory so `subscriptionReactivated()`
/// can return straight to `SessionAuthenticated` without a fresh login.
class SessionSubscriptionInactive extends SessionState {
  final User user;
  final String message;

  const SessionSubscriptionInactive(this.user, {required this.message});

  @override
  List<Object?> get props => [user, message];
}
