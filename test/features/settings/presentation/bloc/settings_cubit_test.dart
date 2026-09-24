import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/authentication/domain/repository/i_auth_repository.dart';
import 'package:hqooq/features/authentication/presentation/bloc/session_cubit.dart';
import 'package:hqooq/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

User _user({String name = 'A B', String? avatarUrl}) => User(
      id: 'u1',
      email: 'a@b.com',
      fullName: name,
      isSuperAdmin: false,
      status: 'ACTIVE',
      mfaEnabled: false,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      avatarUrl: avatarUrl,
    );

void main() {
  late MockAuthRepository repository;
  late SessionCubit sessionCubit;
  late SettingsCubit cubit;

  setUp(() {
    repository = MockAuthRepository();
    sessionCubit = SessionCubit();
    sessionCubit.authenticated(_user(), 'token', isFirmAdmin: false);
    cubit = SettingsCubit(repository, sessionCubit);
  });

  group('client-side validation', () {
    test('empty current password fails without a network call', () async {
      await cubit.submitPasswordChange(
        currentPassword: '',
        newPassword: 'longenough1',
        confirmPassword: 'longenough1',
      );

      expect(cubit.state, isA<PasswordChangeError>().having(
        (s) => s.messageKey,
        'key',
        'password_required',
      ));
      verifyNever(() => repository.changePassword(
            oldPassword: any(named: 'oldPassword'),
            newPassword: any(named: 'newPassword'),
          ));
    });

    test('short new password fails without a network call', () async {
      await cubit.submitPasswordChange(
        currentPassword: 'current1',
        newPassword: 'short',
        confirmPassword: 'short',
      );

      expect(cubit.state, isA<PasswordChangeError>().having(
        (s) => s.messageKey,
        'key',
        'password_min_length|8',
      ));
      verifyNever(() => repository.changePassword(
            oldPassword: any(named: 'oldPassword'),
            newPassword: any(named: 'newPassword'),
          ));
    });

    test('mismatched confirmation fails without a network call', () async {
      await cubit.submitPasswordChange(
        currentPassword: 'current1',
        newPassword: 'longenough1',
        confirmPassword: 'longenough2',
      );

      expect(cubit.state, isA<PasswordChangeError>().having(
        (s) => s.messageKey,
        'key',
        'password_mismatch',
      ));
      verifyNever(() => repository.changePassword(
            oldPassword: any(named: 'oldPassword'),
            newPassword: any(named: 'newPassword'),
          ));
    });
  });

  group('successful change', () {
    test('emits Loading then Success and passes the typed values to the '
        'existing /auth/change-password repository call', () async {
      when(() => repository.changePassword(
            oldPassword: 'current1',
            newPassword: 'longenough1',
          )).thenAnswer((_) async => const Right(null));

      await cubit.submitPasswordChange(
        currentPassword: 'current1',
        newPassword: 'longenough1',
        confirmPassword: 'longenough1',
      );

      expect(cubit.state, isA<PasswordChangeSuccess>());
      verify(() => repository.changePassword(
            oldPassword: 'current1',
            newPassword: 'longenough1',
          )).called(1);
    });

    test('no state ever retains the submitted passwords', () async {
      when(() => repository.changePassword(
            oldPassword: any(named: 'oldPassword'),
            newPassword: any(named: 'newPassword'),
          )).thenAnswer((_) async => const Right(null));

      await cubit.submitPasswordChange(
        currentPassword: 'secret-current',
        newPassword: 'secret-new-1',
        confirmPassword: 'secret-new-1',
      );

      expect(cubit.state, isA<PasswordChangeSuccess>());
      expect(
        cubit.state.toString(),
        isNot(contains('secret-current')),
      );
      expect(cubit.state.toString(), isNot(contains('secret-new-1')));
    });
  });

  group('server failures', () {
    test('wrong current password (401) maps to the wrong-current key',
        () async {
      when(() => repository.changePassword(
            oldPassword: any(named: 'oldPassword'),
            newPassword: any(named: 'newPassword'),
          )).thenAnswer(
          (_) async => const Left(UnauthorizedFailure('Wrong password')));

      await cubit.submitPasswordChange(
        currentPassword: 'wrong-current',
        newPassword: 'longenough1',
        confirmPassword: 'longenough1',
      );

      expect(cubit.state, isA<PasswordChangeError>().having(
        (s) => s.messageKey,
        'key',
        'password_change_wrong_current',
      ));
      expect(cubit.state.toString(), isNot(contains('wrong-current')));
    });

    test('server validation failure (400) maps to the validation key',
        () async {
      when(() => repository.changePassword(
            oldPassword: any(named: 'oldPassword'),
            newPassword: any(named: 'newPassword'),
          )).thenAnswer((_) async =>
          const Left(ValidationFailure('password must contain a digit')));

      await cubit.submitPasswordChange(
        currentPassword: 'current1',
        newPassword: 'longenough1',
        confirmPassword: 'longenough1',
      );

      expect(cubit.state, isA<PasswordChangeError>().having(
        (s) => s.messageKey,
        'key',
        'password_change_validation_error',
      ));
    });

    test('network failure maps to the network key', () async {
      when(() => repository.changePassword(
            oldPassword: any(named: 'oldPassword'),
            newPassword: any(named: 'newPassword'),
          )).thenAnswer((_) async => const Left(NetworkFailure()));

      await cubit.submitPasswordChange(
        currentPassword: 'current1',
        newPassword: 'longenough1',
        confirmPassword: 'longenough1',
      );

      expect(cubit.state, isA<PasswordChangeError>().having(
        (s) => s.messageKey,
        'key',
        'network_error_message',
      ));
    });

    test('a following retry can succeed after a failure', () async {
      var callCount = 0;
      when(() => repository.changePassword(
            oldPassword: any(named: 'oldPassword'),
            newPassword: any(named: 'newPassword'),
          )).thenAnswer((_) async {
        callCount++;
        return callCount == 1
            ? const Left(UnauthorizedFailure())
            : const Right(null);
      });

      await cubit.submitPasswordChange(
        currentPassword: 'wrong',
        newPassword: 'longenough1',
        confirmPassword: 'longenough1',
      );
      expect(cubit.state, isA<PasswordChangeError>());

      await cubit.submitPasswordChange(
        currentPassword: 'right-current',
        newPassword: 'longenough1',
        confirmPassword: 'longenough1',
      );
      expect(cubit.state, isA<PasswordChangeSuccess>());
    });
  });

  group('profile update', () {
    test('empty full name returns false and emits ProfileUpdateError', () async {
      final ok = await cubit.submitProfileUpdate(fullName: '  ');
      expect(ok, isFalse);
      expect(cubit.state, isA<ProfileUpdateError>().having(
        (s) => s.messageKey,
        'key',
        'full_name_required',
      ));
      verifyNever(() => repository.updateProfile(
            fullName: any(named: 'fullName'),
            phone: any(named: 'phone'),
            avatarUrl: any(named: 'avatarUrl'),
          ));
    });

    test('successful update updates SessionCubit and emits ProfileUpdateSuccess',
        () async {
      final updatedUser = _user(name: 'Updated Name', avatarUrl: 'https://example.com/avatar.png');
      when(() => repository.updateProfile(
            fullName: 'Updated Name',
            phone: '123456',
            avatarUrl: 'https://example.com/avatar.png',
          )).thenAnswer((_) async => Right(updatedUser));

      final ok = await cubit.submitProfileUpdate(
        fullName: 'Updated Name',
        phone: '123456',
        avatarUrl: 'https://example.com/avatar.png',
      );

      expect(ok, isTrue);
      expect(cubit.state, isA<ProfileUpdateSuccess>().having(
        (s) => s.user.fullName,
        'fullName',
        'Updated Name',
      ));
      // SessionCubit was immediately updated
      expect(
        (sessionCubit.state as SessionAuthenticated).user.fullName,
        'Updated Name',
      );
    });

    test('failed update maps error and preserves current session', () async {
      when(() => repository.updateProfile(
            fullName: any(named: 'fullName'),
            phone: any(named: 'phone'),
            avatarUrl: any(named: 'avatarUrl'),
          )).thenAnswer(
          (_) async => const Left(ServerFailure('Server error')));

      final ok = await cubit.submitProfileUpdate(
        fullName: 'New Name',
      );

      expect(ok, isFalse);
      expect(cubit.state, isA<ProfileUpdateError>());
      expect(
        (sessionCubit.state as SessionAuthenticated).user.fullName,
        'A B',
      );
    });
  });
}
