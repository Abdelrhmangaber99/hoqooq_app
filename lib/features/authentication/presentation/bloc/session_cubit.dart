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

  /// In-memory only, per BR-033 — never persisted.
  String? get accessToken => _accessToken;

  /// `isFirmAdmin` (BR-005) is computed by the caller as
  /// `myFirm.ownerUserId == user.id` — see `AuthBloc._fetchCurrentUserAndEmit`
  /// and `MyFirm`'s doc comment. Not a property of `User` itself: it
  /// depends on cross-referencing the user against their tenant.
  void authenticated(
    User user,
    String accessToken, {
    required bool isFirmAdmin,
  }) {
    _accessToken = accessToken;
    emit(SessionAuthenticated(user, isFirmAdmin: isFirmAdmin));
  }

  /// Swaps the in-memory access token after a refresh, without changing the
  /// current user or emitting a new state (nothing UI-relevant changed).
  void updateAccessToken(String accessToken) {
    _accessToken = accessToken;
  }

  void unauthenticated() {
    _accessToken = null;
    emit(const SessionUnauthenticated());
  }
}
