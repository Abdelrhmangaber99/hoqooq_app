part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

/// Dispatched once on app start (from the splash screen) to attempt a
/// silent session restore from the stored refresh token.
class SessionRestoreRequested extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}
