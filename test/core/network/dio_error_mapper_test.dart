import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/core/network/dio_error_mapper.dart';

void main() {
  DioException errorWith({required int statusCode, Object? data}) {
    final options = RequestOptions(path: '/test');
    return DioException(
      requestOptions: options,
      response: Response(
        requestOptions: options,
        statusCode: statusCode,
        data: data,
      ),
      type: DioExceptionType.badResponse,
    );
  }

  test('maps connection errors to NetworkFailure', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/test'),
      type: DioExceptionType.connectionError,
    );

    expect(mapDioError(error), isA<NetworkFailure>());
  });

  test('maps 401 to UnauthorizedFailure, surfacing the backend message', () {
    final failure = mapDioError(
      errorWith(statusCode: 401, data: {'message': 'Token expired'}),
    );

    expect(failure, isA<UnauthorizedFailure>());
    expect(failure.message, 'Token expired');
  });

  group('402 (SubscriptionGuard, API_CONTRACT.md finding M)', () {
    test('maps to SubscriptionInactiveFailure, surfacing the real backend '
        'message', () {
      final failure = mapDioError(
        errorWith(
          statusCode: 402,
          data: {
            'message':
                'Your subscription has expired. Please update your billing details.',
          },
        ),
      );

      expect(failure, isA<SubscriptionInactiveFailure>());
      expect(
        failure.message,
        'Your subscription has expired. Please update your billing details.',
      );
    });

    test('falls back to a generic message when the backend omits one', () {
      final failure = mapDioError(errorWith(statusCode: 402, data: null));

      expect(failure, isA<SubscriptionInactiveFailure>());
    });
  });

  test('maps 400 to ValidationFailure', () {
    final failure = mapDioError(
      errorWith(statusCode: 400, data: {'message': 'caseNumber is required'}),
    );

    expect(failure, isA<ValidationFailure>());
    expect(failure.message, 'caseNumber is required');
  });

  test('maps any other status code to ServerFailure', () {
    final failure = mapDioError(errorWith(statusCode: 500, data: null));

    expect(failure, isA<ServerFailure>());
  });
}
