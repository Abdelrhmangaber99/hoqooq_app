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
  const SessionAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated();
}
