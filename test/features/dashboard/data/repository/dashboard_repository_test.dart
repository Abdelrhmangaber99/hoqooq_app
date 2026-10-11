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
      'GETs /dashboard and parses the real total + active case counts',
      () async {
        when(() => dio.get('/dashboard')).thenAnswer(
          (_) async => okResponse('/dashboard', {
            'totalCases': 42,
            'activeCases': 14,
            'pendingTasks': 5,
            'upcomingHearings': 3,
            'recentActivity': <dynamic>[],
          }),
        );

        final result = await repository.getMetrics();

        verify(() => dio.get('/dashboard')).called(1);
        verifyNever(() => dio.get('/reports/dashboard'));
        result.fold((_) => fail('expected Right'), (metrics) {
          expect(metrics.totalCases, 42);
          expect(metrics.totalActiveCases, 14);
          expect(metrics.pendingTasks, 5);
          expect(metrics.upcomingHearings, 3);
        });
      },
    );

    test('tolerates numeric strings and falls back on missing totals', () async {
      when(() => dio.get('/dashboard')).thenAnswer(
        (_) async => okResponse('/dashboard', {
          'totalActiveCases': '14',
          'pendingTasks': 5.9,
          'upcomingHearings': 3,
        }),
      );

      final result = await repository.getMetrics();

      result.fold((_) => fail('expected Right'), (metrics) {
        expect(metrics.totalCases, 14);
        expect(metrics.totalActiveCases, 14);
        expect(metrics.pendingTasks, 5);
      });
    });

    test('maps a server error to ServerFailure', () async {
      when(() => dio.get('/dashboard')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/dashboard'),
          response: Response(
            requestOptions: RequestOptions(path: '/dashboard'),
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
