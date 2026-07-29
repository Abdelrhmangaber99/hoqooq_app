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
      when(
        () => dio.post('/auth/login', data: any(named: 'data')),
      ).thenAnswer((_) async => okResponse('/auth/login', responseBody, statusCode: 201));

      await repository.login(email: 'lawyer@firm.com', password: 'secret123');

      verify(() => dio.post('/auth/login', data: requestBody)).called(1);
    });

    test('returns Right(AuthResponse) with tokens parsed from the response', () async {
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
    });

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
      when(
        () => dio.post('/auth/logout', data: any(named: 'data')),
      ).thenAnswer((_) async => okResponse('/auth/logout', null, statusCode: 204));

      await repository.logout(refreshToken: 'refresh-456');

      verify(
        () => dio.post('/auth/logout', data: {'refreshToken': 'refresh-456'}),
      ).called(1);
    });
  });

  group('getCurrentUser', () {
    // Full shape per API_CONTRACT.md §2 (GET /users/me).
    final userJson = {
      'id': 'u1',
      'email': 'lawyer@firm.com',
      'firstName': 'Jane',
      'lastName': 'Doe',
      'isActive': true,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-01T00:00:00.000Z',
      'roles': [
        {
          'id': 'r1',
          'name': 'LAWYER',
          'displayNameEn': 'Lawyer',
          'displayNameAr': 'محامي',
          'permissions': [
            {
              'id': 'p1',
              'resource': 'cases',
              'action': 'read',
              'displayNameEn': 'Read cases',
              'displayNameAr': 'قراءة القضايا',
            },
          ],
        },
      ],
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
        expect(user.hasPerm('cases', 'read'), isTrue);
        expect(user.hasPerm('cases', 'delete'), isFalse);
        expect(user.tenant.name, 'Reynolds & Associates');
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
      ).thenAnswer((_) async => okResponse('/auth/reset-password', null, statusCode: 204));

      await repository.resetPassword(token: 'reset-tok', newPassword: 'newpw123');

      verify(
        () => dio.post(
          '/auth/reset-password',
          data: {'token': 'reset-tok', 'newPassword': 'newpw123'},
        ),
      ).called(1);
    });

    test('changePassword POSTs exactly {oldPassword, newPassword}', () async {
      when(
        () => dio.post('/auth/change-password', data: any(named: 'data')),
      ).thenAnswer((_) async => okResponse('/auth/change-password', null, statusCode: 204));

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
}
