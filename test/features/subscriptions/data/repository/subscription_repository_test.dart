import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/subscriptions/data/repository/subscription_repository.dart';
import 'package:hqooq/features/subscriptions/domain/entities/subscription_status.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late SubscriptionRepository repository;

  setUp(() {
    dio = MockDio();
    repository = SubscriptionRepository(dio);
  });

  Response<T> okResponse<T>(String path, T data) {
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: data,
      statusCode: 200,
    );
  }

  group('activateSubscription', () {
    test('POSTs /subscriptions/activate with no body and parses the '
        'reactivated subscription', () async {
      when(() => dio.post('/subscriptions/activate')).thenAnswer(
        (_) async => okResponse('/subscriptions/activate', {
          'id': 'sub1',
          'tenantId': 't1',
          'status': 'ACTIVE',
          'currentPeriodEnd': '2026-09-05T00:00:00.000Z',
        }),
      );

      final result = await repository.activateSubscription();

      verify(() => dio.post('/subscriptions/activate')).called(1);
      result.fold((_) => fail('expected Right'), (subscription) {
        expect(subscription.status, SubscriptionStatus.active);
        expect(subscription.tenantId, 't1');
      });
    });

    test(
      'maps a 404 (no subscription row for this tenant) to ServerFailure',
      () async {
        when(() => dio.post('/subscriptions/activate')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/subscriptions/activate'),
            response: Response(
              requestOptions: RequestOptions(path: '/subscriptions/activate'),
              statusCode: 404,
              data: {'message': 'Subscription not found for tenant: t1'},
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        final result = await repository.activateSubscription();

        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('expected Left'),
        );
      },
    );
  });
}
