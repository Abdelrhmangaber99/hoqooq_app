import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'api_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/envelope_interceptor.dart';
import 'interceptors/refresh_interceptor.dart';
import 'interceptors/subscription_interceptor.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(
    AuthInterceptor authInterceptor,
    RefreshInterceptor refreshInterceptor,
    SubscriptionInterceptor subscriptionInterceptor,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(authInterceptor);
    dio.interceptors.add(refreshInterceptor);
    dio.interceptors.add(subscriptionInterceptor);
    dio.interceptors.add(EnvelopeInterceptor());
    dio.interceptors.add(
      // Method/URL/status-code logging only — deliberately never headers or
      // bodies. `LogInterceptor()`'s own bare defaults already log
      // `requestHeader`/`responseHeader` (which would include the bearer
      // token on every single request), and this app previously also
      // explicitly turned on `requestBody`/`responseBody` (login/change-
      // password plaintext, full client/case PII on every response).
      // `Logger()`'s default filter keeps this out of release builds, but
      // that's not a reason to log tokens/PII in every dev session either —
      // fixed at the source instead of relying on the build-mode gate.
      LogInterceptor(
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        logPrint: (object) => Logger().d(object),
      ),
    );

    return dio;
  }
}
