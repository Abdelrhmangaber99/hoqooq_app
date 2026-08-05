import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/network/interceptors/subscription_interceptor.dart';
import 'package:hqooq/features/authentication/presentation/bloc/session_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionCubit extends Mock implements SessionCubit {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  late MockSessionCubit sessionCubit;
  late SubscriptionInterceptor interceptor;
  late MockErrorInterceptorHandler handler;

  setUpAll(() {
    registerFallbackValue(
      DioException(requestOptions: RequestOptions(path: '')),
    );
  });

  setUp(() {
    sessionCubit = MockSessionCubit();
    handler = MockErrorInterceptorHandler();
    interceptor = SubscriptionInterceptor(sessionCubit);
    when(() => sessionCubit.subscriptionInactive(any())).thenReturn(null);
  });

  test('on a 402, notifies SessionCubit with the real backend message and '
      'still passes the error through', () async {
    final options = RequestOptions(path: '/cases');
    final error = DioException(
      requestOptions: options,
      response: Response(
        requestOptions: options,
        statusCode: 402,
        data: {
          'message':
              'Your subscription has expired. Please update your billing details.',
        },
      ),
      type: DioExceptionType.badResponse,
    );

    interceptor.onError(error, handler);

    verify(
      () => sessionCubit.subscriptionInactive(
        'Your subscription has expired. Please update your billing details.',
      ),
    ).called(1);
    verify(() => handler.next(error)).called(1);
  });

  test('falls back to a generic message when the backend omits one', () {
    final options = RequestOptions(path: '/cases');
    final error = DioException(
      requestOptions: options,
      response: Response(requestOptions: options, statusCode: 402),
      type: DioExceptionType.badResponse,
    );

    interceptor.onError(error, handler);

    verify(
      () =>
          sessionCubit.subscriptionInactive('Subscription inactive or expired'),
    ).called(1);
  });

  test('does not touch SessionCubit for a non-402 error', () {
    final options = RequestOptions(path: '/cases');
    final error = DioException(
      requestOptions: options,
      response: Response(requestOptions: options, statusCode: 500),
      type: DioExceptionType.badResponse,
    );

    interceptor.onError(error, handler);

    verifyNever(() => sessionCubit.subscriptionInactive(any()));
    verify(() => handler.next(error)).called(1);
  });
}
