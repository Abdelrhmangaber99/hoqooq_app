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

  test('maps 403 to ForbiddenFailure, surfacing the backend message', () {
    final failure = mapDioError(
      errorWith(
        statusCode: 403,
        data: {'message': 'Missing permission: cases.delete'},
      ),
    );

    expect(failure, isA<ForbiddenFailure>());
    expect(failure.message, 'Missing permission: cases.delete');
  });

  test('maps 400 to ValidationFailure with string or list message', () {
    final failure = mapDioError(
      errorWith(statusCode: 400, data: {'message': 'caseNumber is required'}),
    );

    expect(failure, isA<ValidationFailure>());
    expect(failure.message, 'caseNumber is required');

    final listFailure = mapDioError(
      errorWith(
        statusCode: 400,
        data: {
          'message': ['email must be valid', 'password too short'],
        },
      ),
    );

    expect(listFailure, isA<ValidationFailure>());
    expect(listFailure.message, 'email must be valid');
  });

  test('maps sendTimeout to NetworkFailure', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/test'),
      type: DioExceptionType.sendTimeout,
    );

    expect(mapDioError(error), isA<NetworkFailure>());
  });

  test('maps 422 to ValidationFailure', () {
    final failure = mapDioError(
      errorWith(statusCode: 422, data: {'message': 'Unprocessable entity'}),
    );

    expect(failure, isA<ValidationFailure>());
    expect(failure.message, 'Unprocessable entity');
  });

  // The exact body the deployed backend returns when a database query fails
  // (observed live: an employee completing a task returned
  // `{statusCode:500, message:'Internal server error', error:'QueryFailedError'}`).
  // It must land on `ServerFailure` and never surface the raw sentence.
  test('maps a 500 QueryFailedError envelope to ServerFailure', () {
    final failure = mapDioError(
      errorWith(statusCode: 500, data: {
        'success': false,
        'statusCode': 500,
        'message': 'Internal server error',
        'error': 'QueryFailedError',
        'timestamp': '2026-10-23T04:39:55.565Z',
      }),
    );

    expect(failure, isA<ServerFailure>());
    expect(failure.message, 'Internal server error');
  });

  test('maps 429 and 503 status codes to ServerFailure', () {
    final rateLimit = mapDioError(
      errorWith(statusCode: 429, data: {'message': 'Too many requests'}),
    );
    expect(rateLimit, isA<ServerFailure>());
    expect(rateLimit.message, 'Too many requests');

    final serverError = mapDioError(
      errorWith(statusCode: 503, data: {'message': 'Service unavailable'}),
    );
    expect(serverError, isA<ServerFailure>());
    expect(serverError.message, 'Service unavailable');
  });
}
