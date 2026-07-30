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
        final isFirmAdmin = await _resolveIsFirmAdmin(user);
        _sessionCubit.authenticated(
          user,
          accessToken,
          isFirmAdmin: isFirmAdmin,
        );
        emit(AuthAuthenticated(user));
      },
    );
  }

  /// BR-005: a user is Firm Admin iff they own their tenant
  /// (`myFirm.ownerUserId == user.id` — see `MyFirm`'s doc comment; there
  /// is no dedicated role for this). If `GET /tenants/my-firm` fails for
  /// any reason (e.g. a Super Admin with no tenant at all), default to
  /// `false` — the secure direction, same as the `agreedFee` gating this
  /// exists for in the first place.
  Future<bool> _resolveIsFirmAdmin(User user) async {
    final myFirmResult = await _authRepository.getMyFirm();
    return myFirmResult.fold(
      (_) => false,
      (myFirm) => myFirm.ownerUserId == user.id,
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken != null) {
      // Best-effort: a user-initiated logout must succeed locally even if
      // this network call fails.
      await _authRepository.logout(refreshToken: refreshToken);
    }
    await _tokenStorage.clear();
    _sessionCubit.unauthenticated();
    emit(AuthUnauthenticated());
  }
}
