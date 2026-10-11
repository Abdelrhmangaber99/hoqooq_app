import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/authentication/presentation/bloc/session_cubit.dart';
import 'package:hqooq/features/users/data/repository/user_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late SessionCubit sessionCubit;
  late UserRepository repository;

  setUp(() {
    dio = MockDio();
    sessionCubit = SessionCubit()
      ..authenticated(
        User(
          id: 'current-user',
          email: 'current@firm.com',
          fullName: 'Current User',
          status: 'ACTIVE',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
          tenant: const TenantRef(id: 't1', name: 'Current Firm'),
        ),
        'token',
        isFirmAdmin: false,
      );
    repository = UserRepository(dio, sessionCubit);
  });

  Response<T> okResponse<T>(String path, T data) {
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: data,
      statusCode: 200,
    );
  }

  group('getUsers', () {
    test(
      'uses the tenant employee directory and includes the current user',
      () async {
        when(() => dio.get('/employees')).thenAnswer(
          (_) async => okResponse('/employees', [
            {
              'id': 'employee-1',
              'userId': 'u1',
              'createdAt': '2026-01-01T00:00:00.000Z',
              'updatedAt': '2026-01-01T00:00:00.000Z',
              'user': {
                'id': 'u1',
                'email': 'lawyer@firm.com',
                'fullName': 'Jane Doe',
              },
            },
          ]),
        );

        final result = await repository.getUsers();

        verify(() => dio.get('/employees')).called(1);
        result.fold((_) => fail('expected Right'), (users) {
          expect(users, hasLength(2));
          expect(users.map((user) => user.fullName), contains('Jane Doe'));
          expect(users.map((user) => user.fullName), contains('Current User'));
        });
      },
    );

    test(
      'keeps the current active user when the directory is unavailable',
      () async {
        when(() => dio.get('/employees')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/employees'),
            response: Response(
              requestOptions: RequestOptions(path: '/employees'),
              statusCode: 401,
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        final result = await repository.getUsers();

        result.fold((_) => fail('expected Right'), (users) {
          expect(users.single.fullName, 'Current User');
        });
      },
    );
  });
}
