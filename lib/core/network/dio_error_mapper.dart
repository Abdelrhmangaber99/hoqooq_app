import 'package:dio/dio.dart';
import '../errors/failures.dart';

/// Error responses from this backend are confirmed (from the actual
/// backend source, `src/core/filters/http-exception.filter.ts`) to be
/// `{success: false, statusCode, message, error, timestamp}` — `message`
/// is always a plain string (array validation messages are collapsed to
/// their first element server-side, see `ValidationPipe`'s
/// `forbidNonWhitelisted`/`whitelist` config — a 400 here means either a
/// missing/invalid required field or an extra key the DTO doesn't
/// declare). Shared by every repository so the mapping rule lives in
/// exactly one place.
Failure mapDioError(DioException e) {
  if (e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return const NetworkFailure();
  }
  final statusCode = e.response?.statusCode;
  final backendMessage = _extractBackendMessage(e.response?.data);
  if (statusCode == 401) {
    return backendMessage != null
        ? UnauthorizedFailure(backendMessage)
        : const UnauthorizedFailure();
  }
  if (statusCode == 400) {
    return backendMessage != null
        ? ValidationFailure(backendMessage)
        : const ValidationFailure('Invalid request');
  }
  return backendMessage != null
      ? ServerFailure(backendMessage)
      : const ServerFailure();
}

String? _extractBackendMessage(dynamic data) {
  if (data is Map<String, dynamic>) {
    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;
  }
  return null;
}
