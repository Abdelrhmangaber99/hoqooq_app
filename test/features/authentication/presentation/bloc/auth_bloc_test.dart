import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/core/storage/token_storage.dart';
import 'package:hqooq/features/authentication/data/models/auth_response.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/authentication/domain/repository/i_auth_repository.dart';
import 'package:hqooq/features/authentication/domain/usecases/login_use_case.dart';
import 'package:hqooq/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:hqooq/features/authentication/presentation/bloc/session_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockSessionCubit extends Mock implements SessionCubit {}

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockLoginUseCase loginUseCase;
  late MockAuthRepository authRepository;
  late MockSessionCubit sessionCubit;
  late MockTokenStorage tokenStorage;

  final user = User(
    id: 'u1',
    email: 'lawyer@firm.com',
    fullName: 'Jane Doe',
    isSuperAdmin: false,
    status: 'ACTIVE',
    mfaEnabled: false,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    tenant: const TenantRef(id: 't1', name: 'Reynolds & Associates'),
  );

  final firmAdminUser = user.copyWith(id: 'u2', accountType: 'FIRM_ADMIN');

  const authResponse = AuthResponse(
    accessToken: 'access-123',
    refreshToken: 'refresh-456',
  );

  setUpAll(() {
    registerFallbackValue(user);
  });

  setUp(() {
    loginUseCase = MockLoginUseCase();
    authRepository = MockAuthRepository();
    sessionCubit = MockSessionCubit();
    tokenStorage = MockTokenStorage();

    when(() => tokenStorage.saveRefreshToken(any())).thenAnswer((_) async {});
    when(() => tokenStorage.clear()).thenAnswer((_) async {});
    when(() => sessionCubit.updateAccessToken(any())).thenReturn(null);
    when(
      () => sessionCubit.authenticated(
        any(),
        any(),
        isFirmAdmin: any(named: 'isFirmAdmin'),
      ),
    ).thenReturn(null);
    when(() => sessionCubit.unauthenticated()).thenReturn(null);
  });

  AuthBloc buildBloc() =>
      AuthBloc(loginUseCase, authRepository, sessionCubit, tokenStorage);

  group('LoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Authenticated] on a successful login + GET /users/me',
      build: () {
        when(
          () => loginUseCase.execute(
            email: 'lawyer@firm.com',
            password: 'secret123',
          ),
        ).thenAnswer((_) async => const Right(authResponse));
        when(
          () => authRepository.getCurrentUser(),
        ).thenAnswer((_) async => Right(user));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoginRequested('lawyer@firm.com', 'secret123')),
      expect: () => [isA<AuthLoading>(), AuthAuthenticated(user)],
      verify: (_) {
        verify(() => tokenStorage.saveRefreshToken('refresh-456')).called(1);
        verify(() => sessionCubit.updateAccessToken('access-123')).called(1);
        verify(
          () => sessionCubit.authenticated(
            user,
            'access-123',
            isFirmAdmin: false,
          ),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Authenticated] and marks isFirmAdmin true when the '
      'user holds a FIRM_ADMIN role (BR-005, no network call involved)',
      build: () {
        when(
          () => loginUseCase.execute(
            email: 'lawyer@firm.com',
            password: 'secret123',
          ),
        ).thenAnswer((_) async => const Right(authResponse));
        when(
          () => authRepository.getCurrentUser(),
        ).thenAnswer((_) async => Right(firmAdminUser));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoginRequested('lawyer@firm.com', 'secret123')),
      expect: () => [isA<AuthLoading>(), AuthAuthenticated(firmAdminUser)],
      verify: (_) {
        verify(
          () => sessionCubit.authenticated(
            firmAdminUser,
            'access-123',
            isFirmAdmin: true,
          ),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'marks isFirmAdmin false for a user with no FIRM_ADMIN role',
      build: () {
        when(
          () => loginUseCase.execute(
            email: 'lawyer@firm.com',
            password: 'secret123',
          ),
        ).thenAnswer((_) async => const Right(authResponse));
        when(
          () => authRepository.getCurrentUser(),
        ).thenAnswer((_) async => Right(user));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoginRequested('lawyer@firm.com', 'secret123')),
      expect: () => [isA<AuthLoading>(), AuthAuthenticated(user)],
      verify: (_) {
        verify(
          () => sessionCubit.authenticated(
            user,
            'access-123',
            isFirmAdmin: false,
          ),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Error] when the login call itself fails',
      build: () {
        when(
          () =>
              loginUseCase.execute(email: 'lawyer@firm.com', password: 'wrong'),
        ).thenAnswer((_) async => const Left(UnauthorizedFailure()));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoginRequested('lawyer@firm.com', 'wrong')),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
      verify: (_) {
        verifyNever(() => tokenStorage.saveRefreshToken(any()));
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Error] and clears the session when GET /users/me fails after a successful login',
      build: () {
        when(
          () => loginUseCase.execute(
            email: 'lawyer@firm.com',
            password: 'secret123',
          ),
        ).thenAnswer((_) async => const Right(authResponse));
        when(
          () => authRepository.getCurrentUser(),
        ).thenAnswer((_) async => const Left(ServerFailure()));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoginRequested('lawyer@firm.com', 'secret123')),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
      verify: (_) {
        verify(() => sessionCubit.unauthenticated()).called(1);
      },
    );
  });

  group('SessionRestoreRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Unauthenticated] when there is no stored refresh token',
      build: () {
        when(
          () => tokenStorage.readRefreshToken(),
        ).thenAnswer((_) async => null);
        return buildBloc();
      },
      act: (bloc) => bloc.add(SessionRestoreRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
      verify: (_) {
        verify(() => sessionCubit.unauthenticated()).called(1);
        verifyNever(
          () =>
              authRepository.refresh(refreshToken: any(named: 'refreshToken')),
        );
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Authenticated] when the stored refresh token is still valid',
      build: () {
        when(
          () => tokenStorage.readRefreshToken(),
        ).thenAnswer((_) async => 'old-refresh');
        when(
          () => authRepository.refresh(refreshToken: 'old-refresh'),
        ).thenAnswer((_) async => const Right(authResponse));
        when(
          () => authRepository.getCurrentUser(),
        ).thenAnswer((_) async => Right(user));
        return buildBloc();
      },
      act: (bloc) => bloc.add(SessionRestoreRequested()),
      expect: () => [isA<AuthLoading>(), AuthAuthenticated(user)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Unauthenticated] and clears storage when the stored refresh token is rejected',
      build: () {
        when(
          () => tokenStorage.readRefreshToken(),
        ).thenAnswer((_) async => 'expired-refresh');
        when(
          () => authRepository.refresh(refreshToken: 'expired-refresh'),
        ).thenAnswer((_) async => const Left(UnauthorizedFailure()));
        return buildBloc();
      },
      act: (bloc) => bloc.add(SessionRestoreRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
      verify: (_) {
        verify(() => tokenStorage.clear()).called(1);
        verify(() => sessionCubit.unauthenticated()).called(1);
      },
    );
  });

  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'clears the stored token and emits Unauthenticated, even if the server call fails',
      build: () {
        when(
          () => tokenStorage.readRefreshToken(),
        ).thenAnswer((_) async => 'refresh-456');
        when(
          () => authRepository.logout(refreshToken: 'refresh-456'),
        ).thenAnswer((_) async => const Left(NetworkFailure()));
        return buildBloc();
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [isA<AuthUnauthenticated>()],
      verify: (_) {
        verify(
          () => authRepository.logout(refreshToken: 'refresh-456'),
        ).called(1);
        verify(() => tokenStorage.clear()).called(1);
        verify(() => sessionCubit.unauthenticated()).called(1);
      },
    );
  });
}
