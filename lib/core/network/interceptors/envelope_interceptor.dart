import 'package:dio/dio.dart';

/// Every successful response from this backend is wrapped by a global
/// NestJS interceptor (`src/core/interceptors/transform.interceptor.ts`)
/// in `{ success, statusCode, message, data }` — confirmed by reading the
/// actual backend source, not inferred from the Postman collection (whose
/// example bodies show the bare payload, not this runtime envelope).
///
/// This unwraps `data` transparently so every repository can keep doing
/// `X.fromJson(response.data)` without knowing the envelope exists.
/// Error responses are a different, flatter shape (`{success:false,
/// statusCode, message, error, timestamp}`, confirmed via
/// `http-exception.filter.ts`) and are handled separately in
/// `dio_error_mapper.dart`, since Dio routes non-2xx responses to
/// `onError`, not `onResponse`.
class EnvelopeInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final body = response.data;
    if (body is Map<String, dynamic> &&
        body.containsKey('success') &&
        body.containsKey('data')) {
      response.data = body['data'];
    }
    handler.next(response);
  }
}
