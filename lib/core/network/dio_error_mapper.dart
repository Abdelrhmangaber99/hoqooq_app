import 'package:dio/dio.dart';
import '../errors/failures.dart';

/// No confirmed error-envelope shape exists anywhere in API_CONTRACT.md
/// (every documented error response has an empty body) — mapping is by
/// HTTP status / DioException type only. Revisit once a real error
/// response has been observed. Shared by every repository so the mapping
/// rule lives in exactly one place.
Failure mapDioError(DioException e) {
  if (e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return const NetworkFailure();
  }
  final statusCode = e.response?.statusCode;
  if (statusCode == 401) {
    return const UnauthorizedFailure();
  }
  return const ServerFailure();
}
