import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/users/data/repository/user_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late UserRepository repository;

  setUp(() {
    dio = MockDio();
    repository = UserRepository(dio);
  });

  Response<T> okResponse<T>(String path, T data) {
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: data,
      statusCode: 200,
    );
  }

  group('getUsers', () {
    test('GETs /users and parses the full shape', () async {
      when(() => dio.get('/users')).thenAnswer(
        (_) async => okResponse('/users', [
          {
            'id': 'u1',
            'email': 'lawyer@firm.com',
            'fullName': 'Jane Doe',
            'isSuperAdmin': false,
            'status': 'ACTIVE',
            'mfaEnabled': false,
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-01-01T00:00:00.000Z',
            'roles': <Map<String, dynamic>>[],
            'tenant': {'id': 't1', 'name': 'Reynolds & Associates'},
          },
        ]),
      );

      final result = await repository.getUsers();

      verify(() => dio.get('/users')).called(1);
      result.fold((_) => fail('expected Right'), (users) {
        expect(users, hasLength(1));
        expect(users.first.fullName, 'Jane Doe');
      });
    });

    test('maps a 401 to UnauthorizedFailure', () async {
      when(() => dio.get('/users')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/users'),
          response: Response(
            requestOptions: RequestOptions(path: '/users'),
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await repository.getUsers();

      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
