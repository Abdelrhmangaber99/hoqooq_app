import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/authentication/data/repository/auth_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late AuthRepository repository;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    dio = MockDio();
    repository = AuthRepository(dio);
  });

  Response<T> okResponse<T>(String path, T data, {int statusCode = 200}) {
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: data,
      statusCode: statusCode,
    );
  }

  group('login', () {
    // Exact request/response shape per API_CONTRACT.md §1 (POST /auth/login).
    const requestBody = {'email': 'lawyer@firm.com', 'password': 'secret123'};
    final responseBody = {
      'accessToken': 'access-123',
      'refreshToken': 'refresh-456',
      'user': <String, dynamic>{},
    };

    test('POSTs exactly {email, password} to /auth/login', () async {
      when(() => dio.post('/auth/login', data: any(named: 'data'))).thenAnswer(
        (_) async => okResponse('/auth/login', responseBody, statusCode: 201),
      );

      await repository.login(email: 'lawyer@firm.com', password: 'secret123');

      verify(() => dio.post('/auth/login', data: requestBody)).called(1);
    });

    test(
      'returns Right(AuthResponse) with tokens parsed from the response',
      () async {
        when(
          () => dio.post('/auth/login', data: any(named: 'data')),
        ).thenAnswer((_) async => okResponse('/auth/login', responseBody));

        final result = await repository.login(
          email: 'lawyer@firm.com',
          password: 'secret123',
        );

        expect(result.isRight(), isTrue);
        result.fold((_) => fail('expected Right'), (auth) {
          expect(auth.accessToken, 'access-123');
          expect(auth.refreshToken, 'refresh-456');
        });
      },
    );

    test('maps a 401 to UnauthorizedFailure', () async {
      when(() => dio.post('/auth/login', data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
          response: Response(
            requestOptions: RequestOptions(path: '/auth/login'),
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await repository.login(
        email: 'lawyer@firm.com',
        password: 'wrong',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('maps a connection error to NetworkFailure', () async {
      when(() => dio.post('/auth/login', data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await repository.login(
        email: 'lawyer@firm.com',
        password: 'secret123',
      );

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('refresh', () {
    test('POSTs exactly {refreshToken} to /auth/refresh', () async {
      final responseBody = {
        'accessToken': 'new-access',
        'refreshToken': 'new-refresh',
        'user': <String, dynamic>{},
      };
      when(
        () => dio.post('/auth/refresh', data: any(named: 'data')),
      ).thenAnswer((_) async => okResponse('/auth/refresh', responseBody));

      await repository.refresh(refreshToken: 'old-refresh');

      verify(
        () => dio.post('/auth/refresh', data: {'refreshToken': 'old-refresh'}),
      ).called(1);
    });
  });

  group('logout', () {
    test('POSTs exactly {refreshToken} to /auth/logout', () async {
      when(() => dio.post('/auth/logout', data: any(named: 'data'))).thenAnswer(
        (_) async => okResponse('/auth/logout', null, statusCode: 204),
      );

      await repository.logout(refreshToken: 'refresh-456');

      verify(
        () => dio.post('/auth/logout', data: {'refreshToken': 'refresh-456'}),
      ).called(1);
    });
  });

  group('getCurrentUser', () {
    // Full shape per API_CONTRACT.md §2 (GET /users/me), rebuilt 2026-07-30.
    final userJson = {
      'id': 'u1',
      'email': 'lawyer@firm.com',
      'fullName': 'Jane Doe',
      'accountType': 'EMPLOYEE',
      'status': 'ACTIVE',
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-01T00:00:00.000Z',
      'permissions': ['cases.read'],
      'tenant': {'id': 't1', 'name': 'Reynolds & Associates'},
    };

    test('GETs /users/me and parses the full User shape', () async {
      when(
        () => dio.get('/users/me'),
      ).thenAnswer((_) async => okResponse('/users/me', userJson));

      final result = await repository.getCurrentUser();

      verify(() => dio.get('/users/me')).called(1);
      result.fold((_) => fail('expected Right'), (user) {
        expect(user.id, 'u1');
        expect(user.fullName, 'Jane Doe');
        expect(user.accountType, 'EMPLOYEE');
        expect(user.isSuperAdmin, isFalse);
        expect(user.hasPerm('cases.read'), isTrue);
        expect(user.hasPerm('cases.delete'), isFalse);
        expect(user.tenant?.name, 'Reynolds & Associates');
      });
    });
  });

  group('forgotPassword / resetPassword / changePassword', () {
    test('forgotPassword POSTs exactly {email}', () async {
      when(
        () => dio.post('/auth/forgot-password', data: any(named: 'data')),
      ).thenAnswer((_) async => okResponse('/auth/forgot-password', null));

      await repository.forgotPassword(email: 'lawyer@firm.com');

      verify(
        () => dio.post(
          '/auth/forgot-password',
          data: {'email': 'lawyer@firm.com'},
        ),
      ).called(1);
    });

    test('resetPassword POSTs exactly {token, newPassword}', () async {
      when(
        () => dio.post('/auth/reset-password', data: any(named: 'data')),
      ).thenAnswer(
        (_) async => okResponse('/auth/reset-password', null, statusCode: 204),
      );

      await repository.resetPassword(
        token: 'reset-tok',
        newPassword: 'newpw123',
      );

      verify(
        () => dio.post(
          '/auth/reset-password',
          data: {'token': 'reset-tok', 'newPassword': 'newpw123'},
        ),
      ).called(1);
    });

    test(
      'activateAccount POSTs token and password to /auth/activate',
      () async {
        final responseBody = {
          'accessToken': 'act-access',
          'refreshToken': 'act-refresh',
          'user': <String, dynamic>{},
        };
        when(
          () => dio.post('/auth/activate', data: any(named: 'data')),
        ).thenAnswer((_) async => okResponse('/auth/activate', responseBody));

        final result = await repository.activateAccount(
          token: 'act-token-123',
          password: 'newPassword123',
        );

        verify(
          () => dio.post(
            '/auth/activate',
            data: {'token': 'act-token-123', 'password': 'newPassword123'},
          ),
        ).called(1);
        expect(result.isRight(), isTrue);
        result.fold((_) => fail('expected Right'), (auth) {
          expect(auth?.accessToken, 'act-access');
          expect(auth?.refreshToken, 'act-refresh');
        });
      },
    );

    test('changePassword POSTs exactly {oldPassword, newPassword}', () async {
      when(
        () => dio.post('/auth/change-password', data: any(named: 'data')),
      ).thenAnswer(
        (_) async => okResponse('/auth/change-password', null, statusCode: 204),
      );

      await repository.changePassword(
        oldPassword: 'oldpw123',
        newPassword: 'newpw123',
      );

      verify(
        () => dio.post(
          '/auth/change-password',
          data: {'oldPassword': 'oldpw123', 'newPassword': 'newpw123'},
        ),
      ).called(1);
    });
  });

  group('updateProfile', () {
    final userJson = {
      'id': 'u1',
      'email': 'lawyer@firm.com',
      'fullName': 'Jane Doe',
      'accountType': 'EMPLOYEE',
      'status': 'ACTIVE',
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-02-02T00:00:00.000Z',
      'avatarUrl': 'https://cdn.example.com/avatar.png',
      'permissions': <String>[],
    };

    test('PATCHes /users/me with the avatar URL', () async {
      when(
        () => dio.patch('/users/me', data: any(named: 'data')),
      ).thenAnswer((_) async => okResponse('/users/me', userJson));

      final result = await repository.updateProfile(
        userId: 'u1',
        fullName: 'Jane Doe',
        avatarUrl: 'https://cdn.example.com/avatar.png',
      );

      verify(
        () => dio.patch(
          '/users/me',
          data: {
            'fullName': 'Jane Doe',
            'avatarUrl': 'https://cdn.example.com/avatar.png',
          },
        ),
      ).called(1);
      result.fold((_) => fail('expected Right'), (user) {
        expect(user.avatarUrl, 'https://cdn.example.com/avatar.png');
      });
    });

    test(
      'omits a blank avatarUrl instead of sending an empty string, which the '
      'backend rejects as an invalid URL',
      () async {
        when(
          () => dio.patch('/users/me', data: any(named: 'data')),
        ).thenAnswer((_) async => okResponse('/users/me', userJson));

        await repository.updateProfile(userId: 'u1', avatarUrl: '   ');

        verify(
          () => dio.patch('/users/me', data: <String, dynamic>{}),
        ).called(1);
      },
    );

    test('uses only the deployed self-service route', () async {
      when(
        () => dio.patch('/users/me', data: any(named: 'data')),
      ).thenAnswer((_) async => okResponse('/users/me', userJson));

      final result = await repository.updateProfile(
        userId: 'u1',
        avatarUrl: 'https://cdn.example.com/avatar.png',
      );

      verify(() => dio.patch('/users/me', data: any(named: 'data'))).called(1);
      verifyNever(() => dio.patch('/users/u1', data: any(named: 'data')));
      expect(result.isRight(), isTrue);
    });

    test('maps a real answer such as a 403', () async {
      when(() => dio.patch('/users/me', data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/users/me'),
          type: DioExceptionType.badResponse,
          response: Response<void>(
            requestOptions: RequestOptions(path: '/users/me'),
            statusCode: 403,
          ),
        ),
      );

      final result = await repository.updateProfile(
        userId: 'u1',
        avatarUrl: 'https://cdn.example.com/avatar.png',
      );

      verify(() => dio.patch('/users/me', data: any(named: 'data'))).called(1);
      result.fold(
        (failure) => expect(failure, isA<ForbiddenFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
