import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/user.dart';

part 'session_state.dart';

/// The single source of truth for "is there a valid session right now,"
/// used by both route guards and the Dio auth/refresh interceptors. Kept
/// separate from [AuthBloc], which only tracks the transient UI state of a
/// login attempt (loading/error) — this cubit is what the interceptor
/// updates directly on token refresh/failure without going through a widget
/// tree.
@lazySingleton
class SessionCubit extends Cubit<SessionState> {
  SessionCubit() : super(const SessionUnknown());

  String? _accessToken;

  /// Retained across a `SessionSubscriptionInactive` detour so
  /// `subscriptionReactivated()` can return to `SessionAuthenticated`
  /// without a fresh `GET /users/me` call. Cleared on logout.
  User? _lastUser;

  /// In-memory only, per BR-033 — never persisted.
  String? get accessToken => _accessToken;

  /// `isFirmAdmin` (BR-005) is `user.isFirmAdmin` — see that getter's doc
  /// comment. Passed explicitly rather than read internally so this
  /// method stays a plain setter; `AuthBloc._fetchCurrentUserAndEmit` is
  /// the only caller.
  void authenticated(
    User user,
    String accessToken, {
    required bool isFirmAdmin,
  }) {
    _accessToken = accessToken;
    _lastUser = user;
    emit(SessionAuthenticated(user, isFirmAdmin: isFirmAdmin));
  }

  /// Swaps the in-memory access token after a refresh, without changing the
  /// current user or emitting a new state (nothing UI-relevant changed).
  void updateAccessToken(String accessToken) {
    _accessToken = accessToken;
  }

  void unauthenticated() {
    _accessToken = null;
    _lastUser = null;
    emit(const SessionUnauthenticated());
  }

  /// Called by `SubscriptionInterceptor` on any 402. No-ops if there's no
  /// known user (shouldn't happen — `SubscriptionGuard` only fires for
  /// authenticated requests — but a stale/racing 401-logout could
  /// theoretically land first).
  void subscriptionInactive(String message) {
    final user = _lastUser;
    if (user == null) return;
    emit(SessionSubscriptionInactive(user, message: message));
  }

  /// Called after a successful `POST /subscriptions/activate` — returns
  /// straight to `SessionAuthenticated` using the still-valid access
  /// token (never cleared entering the blocked state, since it wasn't a
  /// logout).
  void subscriptionReactivated() {
    final user = _lastUser;
    if (user == null) return;
    emit(SessionAuthenticated(user, isFirmAdmin: user.isFirmAdmin));
  }
}
