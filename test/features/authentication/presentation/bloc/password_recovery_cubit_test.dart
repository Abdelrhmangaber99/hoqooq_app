import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/authentication/domain/repository/i_auth_repository.dart';
import 'package:hqooq/features/authentication/presentation/bloc/password_recovery_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository repository;
  late PasswordRecoveryCubit cubit;

  setUp(() {
    repository = MockAuthRepository();
    cubit = PasswordRecoveryCubit(repository);
  });

  tearDown(() => cubit.close());

  group('forgot password', () {
    test('rejects an empty email without calling the API', () async {
      await cubit.submitForgotPassword('   ');

      expect(cubit.state, isA<RecoveryFailure>());
      expect((cubit.state as RecoveryFailure).messageKey, 'email_required');
      verifyNever(() => repository.forgotPassword(email: any(named: 'email')));
    });

    test('emits EmailSent on success, trimming the address', () async {
      when(
        () => repository.forgotPassword(email: 'user@firm.sa'),
      ).thenAnswer((_) async => const Right(null));

      await cubit.submitForgotPassword('  user@firm.sa  ');

      expect(cubit.state, isA<RecoveryEmailSent>());
    });

    test('emits Submitting while the request is in flight', () async {
      when(
        () => repository.forgotPassword(email: any(named: 'email')),
      ).thenAnswer((_) async => const Right(null));

      final states = <PasswordRecoveryState>[];
      final subscription = cubit.stream.listen(states.add);
      await cubit.submitForgotPassword('user@firm.sa');
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(states.first, isA<RecoverySubmitting>());
      expect(states.last, isA<RecoveryEmailSent>());
    });

    test('maps a network failure to a localizable key', () async {
      when(
        () => repository.forgotPassword(email: any(named: 'email')),
      ).thenAnswer((_) async => const Left(NetworkFailure()));

      await cubit.submitForgotPassword('user@firm.sa');

      expect(
        (cubit.state as RecoveryFailure).messageKey,
        'network_error_message',
      );
    });
  });

  group('reset password', () {
    test('refuses to post an empty token', () async {
      await cubit.submitResetPassword(
        token: '',
        newPassword: 'NewSecure123',
        confirmPassword: 'NewSecure123',
      );

      expect((cubit.state as RecoveryFailure).messageKey, 'invalid_reset_link');
      verifyNever(
        () => repository.resetPassword(
          token: any(named: 'token'),
          newPassword: any(named: 'newPassword'),
        ),
      );
    });

    test('enforces the 8-character minimum locally', () async {
      await cubit.submitResetPassword(
        token: 'tok',
        newPassword: 'short',
        confirmPassword: 'short',
      );

      expect(
        (cubit.state as RecoveryFailure).messageKey,
        'password_min_length',
      );
      verifyNever(
        () => repository.resetPassword(
          token: any(named: 'token'),
          newPassword: any(named: 'newPassword'),
        ),
      );
    });

    test('rejects mismatched confirmation', () async {
      await cubit.submitResetPassword(
        token: 'tok',
        newPassword: 'NewSecure123',
        confirmPassword: 'NewSecure124',
      );

      expect((cubit.state as RecoveryFailure).messageKey, 'password_mismatch');
      verifyNever(
        () => repository.resetPassword(
          token: any(named: 'token'),
          newPassword: any(named: 'newPassword'),
        ),
      );
    });

    test('emits PasswordReset on success', () async {
      when(
        () =>
            repository.resetPassword(token: 'tok', newPassword: 'NewSecure123'),
      ).thenAnswer((_) async => const Right(null));

      await cubit.submitResetPassword(
        token: 'tok',
        newPassword: 'NewSecure123',
        confirmPassword: 'NewSecure123',
      );

      expect(cubit.state, isA<RecoveryPasswordReset>());
    });

    test('treats a rejected token as an invalid link', () async {
      when(
        () => repository.resetPassword(
          token: any(named: 'token'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => const Left(ValidationFailure('Invalid token')));

      await cubit.submitResetPassword(
        token: 'expired',
        newPassword: 'NewSecure123',
        confirmPassword: 'NewSecure123',
      );

      expect((cubit.state as RecoveryFailure).messageKey, 'invalid_reset_link');
    });

    test('no password ever appears in the emitted state', () async {
      when(
        () => repository.resetPassword(
          token: any(named: 'token'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => const Left(ValidationFailure('Invalid token')));

      await cubit.submitResetPassword(
        token: 'tok',
        newPassword: 'NewSecure123',
        confirmPassword: 'NewSecure123',
      );

      expect(cubit.state.toString(), isNot(contains('NewSecure123')));
    });
  });
}
