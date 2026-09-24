import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repository/i_auth_repository.dart';
import '../../domain/usecases/login_use_case.dart';
import 'session_cubit.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Transient UI state for a login attempt (loading/error) plus session
/// restore on app start. The persisted "is there a valid session" truth
/// lives in [SessionCubit] — this bloc drives it, route guards and the Dio
/// interceptors read it directly.
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final IAuthRepository _authRepository;
  final SessionCubit _sessionCubit;
  final TokenStorage _tokenStorage;

  AuthBloc(
    this._loginUseCase,
    this._authRepository,
    this._sessionCubit,
    this._tokenStorage,
  ) : super(AuthInitial()) {
    on<SessionRestoreRequested>(_onSessionRestoreRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onSessionRestoreRequested(
    SessionRestoreRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final storedRefreshToken = await _tokenStorage.readRefreshToken();
    if (storedRefreshToken == null) {
      _sessionCubit.unauthenticated();
      emit(AuthUnauthenticated());
      return;
    }

    final refreshResult = await _authRepository.refresh(
      refreshToken: storedRefreshToken,
    );

    final newAccessToken = await refreshResult.fold(
      (failure) async {
        await _tokenStorage.clear();
        _sessionCubit.unauthenticated();
        return null;
      },
      (auth) async {
        await _tokenStorage.saveRefreshToken(auth.refreshToken);
        _sessionCubit.updateAccessToken(auth.accessToken);
        return auth.accessToken;
      },
    );

    if (newAccessToken == null) {
      emit(AuthUnauthenticated());
      return;
    }

    await _fetchCurrentUserAndEmit(newAccessToken, emit);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final loginResult = await _loginUseCase.execute(
      email: event.email,
      password: event.password,
    );

    final newAccessToken = await loginResult.fold(
      (failure) async {
        emit(AuthError(failure.message));
        return null;
      },
      (auth) async {
        await _tokenStorage.saveRefreshToken(auth.refreshToken);
        _sessionCubit.updateAccessToken(auth.accessToken);
        return auth.accessToken;
      },
    );

    if (newAccessToken == null) return;

    await _fetchCurrentUserAndEmit(newAccessToken, emit);
  }

  /// Login/refresh responses don't reliably carry a full user object (see
  /// AuthResponse) — the canonical user always comes from `GET /users/me`,
  /// called once the new access token is already in place.
  Future<void> _fetchCurrentUserAndEmit(
    String accessToken,
    Emitter<AuthState> emit,
  ) async {
    final meResult = await _authRepository.getCurrentUser();
    await meResult.fold(
      (failure) async {
        _sessionCubit.unauthenticated();
        emit(AuthError(failure.message));
      },
      (user) async {
        _sessionCubit.authenticated(
          user,
          accessToken,
          isFirmAdmin: user.isFirmAdmin,
        );
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    // End the local session before contacting the server. Logout must always
    // reach the login route, even when the access token has expired, the
    // device is offline, or the server logout endpoint fails.
    await _tokenStorage.clear();
    _sessionCubit.unauthenticated();
    emit(AuthUnauthenticated());

    if (refreshToken != null) {
      // Revocation is best-effort and must not delay navigation. The refresh
      // token is captured before local storage is cleared.
      unawaited(_authRepository.logout(refreshToken: refreshToken));
    }
  }
}
