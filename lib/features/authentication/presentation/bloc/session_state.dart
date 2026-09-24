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
