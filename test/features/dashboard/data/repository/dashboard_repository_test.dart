import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/dashboard/data/repository/dashboard_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late DashboardRepository repository;

  setUp(() {
    dio = MockDio();
    repository = DashboardRepository(dio);
  });

  Response<T> okResponse<T>(String path, T data) {
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: data,
      statusCode: 200,
    );
  }

  group('getMetrics', () {
    test(
      'GETs /reports/dashboard (not /dashboard) and parses the shape',
      () async {
        when(() => dio.get('/reports/dashboard')).thenAnswer(
          (_) async => okResponse('/reports/dashboard', {
            'totalActiveCases': 14,
            'pendingTasks': 5,
            'upcomingHearings': 3,
          }),
        );

        final result = await repository.getMetrics();

        verify(() => dio.get('/reports/dashboard')).called(1);
        verifyNever(() => dio.get('/dashboard'));
        result.fold((_) => fail('expected Right'), (metrics) {
          expect(metrics.totalActiveCases, 14);
          expect(metrics.pendingTasks, 5);
          expect(metrics.upcomingHearings, 3);
        });
      },
    );

    test('maps a server error to ServerFailure', () async {
      when(() => dio.get('/reports/dashboard')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/reports/dashboard'),
          response: Response(
            requestOptions: RequestOptions(path: '/reports/dashboard'),
            statusCode: 500,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await repository.getMetrics();

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
