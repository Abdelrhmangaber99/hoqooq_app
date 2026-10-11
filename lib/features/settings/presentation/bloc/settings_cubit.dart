import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../authentication/domain/repository/i_auth_repository.dart';
import '../../../authentication/presentation/bloc/session_cubit.dart';

/// Password-change and profile form state. Passwords are never logged, never
/// persisted, and never included in error output. On success, sensitive fields
/// are cleared. Profile updates call [SessionCubit.updateUser] so all UI
/// consumers immediately reflect the changes without manual refresh.
@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final IAuthRepository _authRepository;
  final SessionCubit _sessionCubit;

  /// [sessionCubit] is required, not optional: a profile save has to push
  /// the updated user back into the session so every dependent widget
  /// (app bar, profile header, settings) rebuilds with the new values.
  /// When it was nullable and left out of the DI registration, the call
  /// silently became a no-op and profile changes never propagated.
  SettingsCubit(this._authRepository, this._sessionCubit)
    : super(const SettingsInitial());

  /// Minimum length enforced by the backend password DTO; mirrored
  /// client-side so the user gets immediate feedback without a round trip.
  static const int minPasswordLength = 8;

  Future<void> submitPasswordChange({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // Client-side validation first — identical messages to what the server
    // would return so the UI copy stays in one place (see l10n keys).
    if (currentPassword.isEmpty) {
      emit(const PasswordChangeError('password_required'));
      return;
    }
    if (newPassword.isEmpty) {
      emit(const PasswordChangeError('new_password_required'));
      return;
    }
    if (newPassword.length < minPasswordLength) {
      emit(PasswordChangeError('password_min_length|$minPasswordLength'));
      return;
    }
    if (newPassword != confirmPassword) {
      emit(const PasswordChangeError('password_mismatch'));
      return;
    }

    // Clear any previous failure before submitting; duplicate submission is
    // impossible while [PasswordChangeLoading] because the submitting UI
    // disables the action (and callers guard on isLoading anyway).
    emit(const PasswordChangeLoading());
    final result = await _authRepository.changePassword(
      oldPassword: currentPassword,
      newPassword: newPassword,
    );
    // Await the fold so [submitPasswordChange] resolves only after the
    // terminal state (Success/Error) has been emitted.
    await result.fold((failure) async {
      // Map typed failures to stable, localizable message keys. Never
      // surfaces raw exception data (could contain request internals).
      final messageKey = switch (failure) {
        ValidationFailure() => 'password_change_validation_error',
        UnauthorizedFailure() => 'password_change_wrong_current',
        ForbiddenFailure() => 'password_change_forbidden',
        NetworkFailure() => 'network_error_message',
        _ => 'password_change_generic_error',
      };
      emit(PasswordChangeError(messageKey));
    }, (_) async => emit(const PasswordChangeSuccess()));
  }

  Future<bool> submitProfileUpdate({
    required String fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    if (fullName.trim().isEmpty) {
      emit(const ProfileUpdateError('full_name_required'));
      return false;
    }

    // The update is addressed to the session user's own account, so a save
    // without a signed-in user (or without an id) cannot be attempted.
    final session = _sessionCubit.state;
    if (session is! SessionAuthenticated) {
      emit(const ProfileUpdateError('could_not_update_profile'));
      return false;
    }

    emit(const ProfileUpdateLoading());
    final result = await _authRepository.updateProfile(
      userId: session.user.id,
      fullName: fullName.trim(),
      phone: phone?.trim(),
      avatarUrl: avatarUrl?.trim(),
    );

    return result.fold(
      (failure) {
        // A stable key when there is nothing specific to say, otherwise the
        // failure's own text — the display site resolves either form for the
        // active locale (see `localizedErrorKeyOrMessage`). Never a
        // hard-coded language here.
        final messageKey = failure.message.isNotEmpty
            ? failure.message
            : 'could_not_update_profile';
        emit(ProfileUpdateError(messageKey));
        return false;
      },
      (updatedUser) {
        _sessionCubit.updateUser(updatedUser);
        emit(ProfileUpdateSuccess(updatedUser));
        return true;
      },
    );
  }
}

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class PasswordChangeLoading extends SettingsState {
  const PasswordChangeLoading();
}

class PasswordChangeSuccess extends SettingsState {
  const PasswordChangeSuccess();
}

/// Carries either a client-side validation key or a server failure key —
/// plain strings only, never the submitted passwords.
class PasswordChangeError extends SettingsState {
  final String messageKey;

  const PasswordChangeError(this.messageKey);

  @override
  List<Object?> get props => [messageKey];
}

class ProfileUpdateLoading extends SettingsState {
  const ProfileUpdateLoading();
}

class ProfileUpdateSuccess extends SettingsState {
  final User user;

  const ProfileUpdateSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileUpdateError extends SettingsState {
  final String messageKey;

  const ProfileUpdateError(this.messageKey);

  @override
  List<Object?> get props => [messageKey];
}
