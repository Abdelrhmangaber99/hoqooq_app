import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/repository/i_auth_repository.dart';

/// Drives the two unauthenticated password-recovery flows, which the backend
/// exposes as separate endpoints from the authenticated password change:
///
///  * **forgot password** — `POST /auth/forgot-password` (email in, a generic
///    confirmation out, whether or not the address exists).
///  * **reset password** — `POST /auth/reset-password` (the token from the
///    emailed link plus the new password).
///
/// Deliberately separate from `AuthBloc` (sign-in attempts) and from
/// `SettingsCubit` (authenticated change in Settings), and instantiated per
/// page rather than registered in DI, so recovery state cannot leak into the
/// signed-in UI. Method-based for the same reason a single event class per
/// call would only add ceremony.
class PasswordRecoveryCubit extends Cubit<PasswordRecoveryState> {
  PasswordRecoveryCubit(this._repository) : super(const RecoveryIdle());

  final IAuthRepository _repository;

  /// Mirrors `ChangePasswordDto`/`ResetPasswordDto`'s `@MinLength(8)` so the
  /// user gets the same rule without a round trip.
  static const int minPasswordLength = 8;

  Future<void> submitForgotPassword(String email) async {
    final address = email.trim();
    if (address.isEmpty) {
      emit(const RecoveryFailure('email_required'));
      return;
    }
    emit(const RecoverySubmitting());
    final result = await _repository.forgotPassword(email: address);
    result.fold(
      (failure) => emit(
        RecoveryFailure(_messageKey(failure, validationKey: 'email_required')),
      ),
      (_) => emit(const RecoveryEmailSent()),
    );
  }

  Future<void> submitResetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (token.isEmpty) {
      emit(const RecoveryFailure('invalid_reset_link'));
      return;
    }
    if (newPassword.isEmpty) {
      emit(const RecoveryFailure('new_password_required'));
      return;
    }
    if (newPassword.length < minPasswordLength) {
      emit(const RecoveryFailure('password_min_length'));
      return;
    }
    if (newPassword != confirmPassword) {
      emit(const RecoveryFailure('password_mismatch'));
      return;
    }
    emit(const RecoverySubmitting());
    final result = await _repository.resetPassword(
      token: token,
      newPassword: newPassword,
    );
    result.fold(
      (failure) => emit(
        RecoveryFailure(
          _messageKey(failure, validationKey: 'invalid_reset_link'),
        ),
      ),
      (_) => emit(const RecoveryPasswordReset()),
    );
  }

  /// Maps a typed failure to a stable, localizable key. These endpoints are
  /// unauthenticated, so nothing the server echoes back is ever rendered
  /// verbatim — and no submitted password reaches a message, a log, or a
  /// state value: only keys and success tokens live in this cubit.
  String _messageKey(Failure failure, {required String validationKey}) {
    return switch (failure) {
      // 400/422: a malformed address, or an expired/already-used token.
      ValidationFailure() => validationKey,
      UnauthorizedFailure() => validationKey,
      NetworkFailure() => 'network_error_message',
      _ => 'recovery_failed',
    };
  }
}

abstract class PasswordRecoveryState extends Equatable {
  const PasswordRecoveryState();

  @override
  List<Object?> get props => [];
}

class RecoveryIdle extends PasswordRecoveryState {
  const RecoveryIdle();
}

/// A recovery request is in flight. The submit action is disabled in this
/// state, so a duplicate submission cannot be issued.
class RecoverySubmitting extends PasswordRecoveryState {
  const RecoverySubmitting();
}

/// `forgot-password` accepted the request. The copy stays generic on
/// purpose: it must not reveal whether the address exists.
class RecoveryEmailSent extends PasswordRecoveryState {
  const RecoveryEmailSent();
}

class RecoveryPasswordReset extends PasswordRecoveryState {
  const RecoveryPasswordReset();
}

/// Carries a message *key* (or a server message for non-sensitive failures
/// mapped through [PasswordRecoveryCubit._messageKey]) — never a password.
class RecoveryFailure extends PasswordRecoveryState {
  const RecoveryFailure(this.messageKey);

  final String messageKey;

  @override
  List<Object?> get props => [messageKey];
}
