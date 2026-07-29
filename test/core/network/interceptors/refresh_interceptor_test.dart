import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/network/interceptors/refresh_interceptor.dart';
import 'package:hqooq/core/storage/token_storage.dart';
import 'package:hqooq/features/authentication/presentation/bloc/session_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockTokenStorage extends Mock implements TokenStorage {}

class MockSessionCubit extends Mock implements SessionCubit {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  late MockDio rawDio;
  late MockTokenStorage tokenStorage;
  late MockSessionCubit sessionCubit;
  late RefreshInterceptor interceptor;
  late MockErrorInterceptorHandler handler;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(
      Response<dynamic>(requestOptions: RequestOptions(path: '')),
    );
    registerFallbackValue(
      DioException(requestOptions: RequestOptions(path: '')),
    );
  });

  setUp(() {
    rawDio = MockDio();
    tokenStorage = MockTokenStorage();
    sessionCubit = MockSessionCubit();
    handler = MockErrorInterceptorHandler();
    interceptor = RefreshInterceptor.withDio(tokenStorage, sessionCubit, rawDio);
  });

  DioException unauthorizedError({bool alreadyRetried = false}) {
    final options = RequestOptions(
      path: '/cases',
      extra: alreadyRetried ? {'hoqooq_refresh_retried': true} : {},
    );
    return DioException(
      requestOptions: options,
      response: Response(requestOptions: options, statusCode: 401),
      type: DioExceptionType.badResponse,
    );
  }

  test('passes through non-401 errors without attempting a refresh', () async {
    final error = DioException(
      requestOptions: RequestOptions(path: '/cases'),
      type: DioExceptionType.connectionError,
    );

    interceptor.onError(error, handler);
    await untilCalled(() => handler.next(any()));

    verify(() => handler.next(error)).called(1);
    verifyNever(() => rawDio.post(any(), data: any(named: 'data')));
  });

  test('does not retry a request that has already been retried once', () async {
    final error = unauthorizedError(alreadyRetried: true);

    interceptor.onError(error, handler);
    await untilCalled(() => handler.next(any()));

    verify(() => handler.next(error)).called(1);
    verifyNever(() => tokenStorage.readRefreshToken());
  });

  test(
    'with no stored refresh token: clears session and passes the error through',
    () async {
      when(() => tokenStorage.readRefreshToken()).thenAnswer((_) async => null);
      final error = unauthorizedError();

      interceptor.onError(error, handler);
      await untilCalled(() => handler.next(any()));

      verify(() => sessionCubit.unauthenticated()).called(1);
      verify(() => handler.next(error)).called(1);
      verifyNever(() => rawDio.post(any(), data: any(named: 'data')));
    },
  );

  test(
    'on successful refresh: rotates the token and retries the original request',
    () async {
      when(
        () => tokenStorage.readRefreshToken(),
      ).thenAnswer((_) async => 'old-refresh');
      when(
        () => tokenStorage.saveRefreshToken(any()),
      ).thenAnswer((_) async {});
      when(() => sessionCubit.updateAccessToken(any())).thenReturn(null);
      when(() => rawDio.post('/auth/refresh', data: {'refreshToken': 'old-refresh'}))
          .thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          statusCode: 200,
          data: {
            'accessToken': 'new-access',
            'refreshToken': 'new-refresh',
            'user': <String, dynamic>{},
          },
        ),
      );
      final retriedResponse = Response(
        requestOptions: RequestOptions(path: '/cases'),
        statusCode: 200,
        data: [],
      );
      when(() => rawDio.fetch(any())).thenAnswer((_) async => retriedResponse);

      final error = unauthorizedError();
      interceptor.onError(error, handler);
      await untilCalled(() => handler.resolve(any()));

      verify(
        () => rawDio.post('/auth/refresh', data: {'refreshToken': 'old-refresh'}),
      ).called(1);
      verify(() => tokenStorage.saveRefreshToken('new-refresh')).called(1);
      verify(() => sessionCubit.updateAccessToken('new-access')).called(1);

      final captured = verify(() => rawDio.fetch<dynamic>(captureAny())).captured;
      final retriedOptions = captured.single as RequestOptions;
      expect(retriedOptions.headers['Authorization'], 'Bearer new-access');
      expect(retriedOptions.extra['hoqooq_refresh_retried'], isTrue);

      verify(() => handler.resolve(retriedResponse)).called(1);
    },
  );

  test(
    'on failed refresh: clears the stored token, clears the session, passes the original error through',
    () async {
      when(
        () => tokenStorage.readRefreshToken(),
      ).thenAnswer((_) async => 'old-refresh');
      when(() => tokenStorage.clear()).thenAnswer((_) async {});
      when(
        () => rawDio.post('/auth/refresh', data: any(named: 'data')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          response: Response(
            requestOptions: RequestOptions(path: '/auth/refresh'),
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final error = unauthorizedError();
      interceptor.onError(error, handler);
      await untilCalled(() => handler.next(any()));

      verify(() => tokenStorage.clear()).called(1);
      verify(() => sessionCubit.unauthenticated()).called(1);
      verify(() => handler.next(error)).called(1);
      verifyNever(() => rawDio.fetch(any()));
    },
  );
}
