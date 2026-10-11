import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/authentication/data/models/auth_response.dart';
import 'package:hqooq/features/authentication/domain/repository/i_auth_repository.dart';
import 'package:hqooq/features/authentication/presentation/bloc/account_activation_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository repository;
  late AccountActivationCubit cubit;

  setUp(() {
    repository = MockAuthRepository();
    cubit = AccountActivationCubit(repository);
  });

  tearDown(() => cubit.close());

  group('account activation', () {
    test('refuses to submit with empty token', () async {
      await cubit.submitActivation(
        token: '',
        newPassword: 'NewPassword123',
        confirmPassword: 'NewPassword123',
      );

      expect(cubit.state, isA<AccountActivationFailure>());
      expect(
        (cubit.state as AccountActivationFailure).messageKey,
        'invalid_activation_link',
      );
      verifyNever(
        () => repository.activateAccount(
          token: any(named: 'token'),
          password: any(named: 'password'),
        ),
      );
    });

    test('enforces password minimum length of 8', () async {
      await cubit.submitActivation(
        token: 'token123',
        newPassword: 'short',
        confirmPassword: 'short',
      );

      expect(cubit.state, isA<AccountActivationFailure>());
      expect(
        (cubit.state as AccountActivationFailure).messageKey,
        'password_min_length',
      );
      verifyNever(
        () => repository.activateAccount(
          token: any(named: 'token'),
          password: any(named: 'password'),
        ),
      );
    });

    test('rejects mismatched password confirmation', () async {
      await cubit.submitActivation(
        token: 'token123',
        newPassword: 'NewPassword123',
        confirmPassword: 'DifferentPassword123',
      );

      expect(cubit.state, isA<AccountActivationFailure>());
      expect(
        (cubit.state as AccountActivationFailure).messageKey,
        'password_mismatch',
      );
      verifyNever(
        () => repository.activateAccount(
          token: any(named: 'token'),
          password: any(named: 'password'),
        ),
      );
    });

    test('emits AccountActivationSuccess on successful API response', () async {
      final authResponse = AuthResponse(
        accessToken: 'access-123',
        refreshToken: 'refresh-456',
        user: dynamicUser(),
      );
      when(
        () => repository.activateAccount(
          token: 'token123',
          password: 'NewPassword123',
        ),
      ).thenAnswer((_) async => Right(authResponse));

      await cubit.submitActivation(
        token: 'token123',
        newPassword: 'NewPassword123',
        confirmPassword: 'NewPassword123',
      );

      expect(cubit.state, isA<AccountActivationSuccess>());
      expect(
        (cubit.state as AccountActivationSuccess).authResponse?.accessToken,
        'access-123',
      );
    });

    test('maps network failure to localizable key', () async {
      when(
        () => repository.activateAccount(
          token: any(named: 'token'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Left(NetworkFailure()));

      await cubit.submitActivation(
        token: 'token123',
        newPassword: 'NewPassword123',
        confirmPassword: 'NewPassword123',
      );

      expect(cubit.state, isA<AccountActivationFailure>());
      expect(
        (cubit.state as AccountActivationFailure).messageKey,
        'network_error_message',
      );
    });
  });
}

dynamicUser() {
  return dynamicUserWithJson({
    'id': 'u1',
    'email': 'firmadmin@law.com',
    'fullName': 'Firm Admin',
    'accountType': 'EMPLOYEE',
    'status': 'ACTIVE',
    'createdAt': '2026-01-01T00:00:00.000Z',
    'updatedAt': '2026-01-01T00:00:00.000Z',
    'permissions': ['tenants.read'],
  });
}

dynamicUserWithJson(Map<String, dynamic> json) => AuthResponse.fromJson({
  'accessToken': 'a',
  'refreshToken': 'r',
  'user': json,
}).user;
