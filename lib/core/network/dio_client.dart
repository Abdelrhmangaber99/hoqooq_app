import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'api_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/envelope_interceptor.dart';
import 'interceptors/refresh_interceptor.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(
    AuthInterceptor authInterceptor,
    RefreshInterceptor refreshInterceptor,
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
    dio.interceptors.add(EnvelopeInterceptor());
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => Logger().d(object),
      ),
    );

    return dio;
  }
}
