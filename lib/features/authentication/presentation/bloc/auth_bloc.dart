import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
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
    try {
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

      // A failed `GET /users/me` (offline, a payload this app can't decode,
      // …) must still land the user on the sign-in screen. Previously it
      // emitted only `AuthError`, which the splash screen doesn't react to —
      // so it sat on the loading screen forever.
      final restored = await _fetchCurrentUserAndEmit(newAccessToken, emit);
      if (!restored) emit(AuthUnauthenticated());
    } catch (_) {
      // Any unexpected, non-`Failure` error thrown while restoring (e.g. a
      // wire shape this app doesn't understand yet, which used to escape the
      // event handler entirely) leaves the splash screen hanging: fail closed
      // to signed-out instead, so the user can sign in again.
      await _tokenStorage.clear();
      _sessionCubit.unauthenticated();
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
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
    } catch (_) {
      // Without this, an unexpected throw (a payload the app can't decode,
      // for example) escapes the event handler while the state is still
      // [AuthLoading] — the sign-in button spins forever with no way back.
      // Fail visibly instead; `localizedErrorMessage` translates this
      // message like every other `Failure`.
      emit(AuthError(const ServerFailure().message));
    }
  }

  /// Login/refresh responses don't reliably carry a full user object (see
  /// AuthResponse) — the canonical user always comes from `GET /users/me`,
  /// called once the new access token is already in place. Returns whether the
  /// session ended up authenticated, so callers can distinguish "signed in"
  /// from "this attempt failed" without re-reading the emitted state.
  Future<bool> _fetchCurrentUserAndEmit(
    String accessToken,
    Emitter<AuthState> emit,
  ) async {
    final meResult = await _authRepository.getCurrentUser();
    return meResult.fold(
      (failure) {
        _sessionCubit.unauthenticated();
        emit(AuthError(failure.message));
        return false;
      },
      (user) {
        _sessionCubit.authenticated(
          user,
          accessToken,
          isFirmAdmin: user.isFirmAdmin,
        );
        emit(AuthAuthenticated(user));
        return true;
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
