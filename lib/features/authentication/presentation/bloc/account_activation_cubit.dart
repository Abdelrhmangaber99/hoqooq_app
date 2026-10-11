import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/auth_response.dart';
import '../../domain/repository/i_auth_repository.dart';

/// Drives the account-activation flow (`POST /auth/activate`), reached via
/// the emailed token link (`/activate?token=...`).
class AccountActivationCubit extends Cubit<AccountActivationState> {
  AccountActivationCubit(this._repository)
      : super(const AccountActivationIdle());

  final IAuthRepository _repository;

  static const int minPasswordLength = 8;

  Future<void> submitActivation({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (token.isEmpty) {
      emit(const AccountActivationFailure('invalid_activation_link'));
      return;
    }
    if (newPassword.isEmpty) {
      emit(const AccountActivationFailure('new_password_required'));
      return;
    }
    if (newPassword.length < minPasswordLength) {
      emit(const AccountActivationFailure('password_min_length'));
      return;
    }
    if (newPassword != confirmPassword) {
      emit(const AccountActivationFailure('password_mismatch'));
      return;
    }
    emit(const AccountActivationSubmitting());
    final result = await _repository.activateAccount(
      token: token,
      password: newPassword,
    );
    result.fold(
      (failure) => emit(
        AccountActivationFailure(
          _messageKey(failure, validationKey: 'invalid_activation_link'),
        ),
      ),
      (authResponse) => emit(AccountActivationSuccess(authResponse)),
    );
  }

  String _messageKey(Failure failure, {required String validationKey}) {
    return switch (failure) {
      ValidationFailure() => validationKey,
      UnauthorizedFailure() => validationKey,
      NetworkFailure() => 'network_error_message',
      _ => 'activation_failed',
    };
  }
}

abstract class AccountActivationState extends Equatable {
  const AccountActivationState();

  @override
  List<Object?> get props => [];
}

class AccountActivationIdle extends AccountActivationState {
  const AccountActivationIdle();
}

class AccountActivationSubmitting extends AccountActivationState {
  const AccountActivationSubmitting();
}

class AccountActivationSuccess extends AccountActivationState {
  const AccountActivationSuccess(this.authResponse);

  final AuthResponse? authResponse;

  @override
  List<Object?> get props => [authResponse];
}

class AccountActivationFailure extends AccountActivationState {
  const AccountActivationFailure(this.messageKey);

  final String messageKey;

  @override
  List<Object?> get props => [messageKey];
}
