import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/service_process.dart';
import '../../domain/repository/i_service_process_repository.dart';
import '../models/create_service_process_request.dart';
import '../models/complete_service_process_request.dart';
import '../models/update_service_process_request.dart';

@LazySingleton(as: IServiceProcessRepository)
class ServiceProcessRepository implements IServiceProcessRepository {
  ServiceProcessRepository(this._dio);
  final Dio _dio;

  @override
  ApiResult<List<ServiceProcess>> getForCase(String caseId) async {
    try {
      final response = await _dio.get(
        '/service-of-process',
        queryParameters: {'caseId': caseId},
      );
      return Right(
        (response.data as List<dynamic>)
            .map(
              (item) => ServiceProcess.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
      );
    } on DioException catch (error) {
      return Left(mapDioError(error));
    } catch (_) {
      // A payload that doesn't match the entity shape must fail as an
      // `ApiResult`, never as a thrown exception: an uncaught decode error
      // escapes the calling bloc's event handler before it can emit, which
      // pins the screen on its loading spinner instead of showing an error.
      return const Left(ServerFailure());
    }
  }

  @override
  ApiResult<ServiceProcess> create(CreateServiceProcessRequest request) async {
    try {
      final response = await _dio.post(
        '/service-of-process',
        data: request.toJson(),
      );
      return Right(
        ServiceProcess.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (error) {
      return Left(mapDioError(error));
    }
  }

  @override
  ApiResult<ServiceProcess> update(
    String id,
    UpdateServiceProcessRequest request,
  ) async {
    try {
      final response = await _dio.patch(
        '/service-of-process/$id',
        data: request.toJson(),
      );
      return Right(
        ServiceProcess.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (error) {
      return Left(mapDioError(error));
    }
  }

  @override
  ApiResult<ServiceProcess> complete(
    String id,
    CompleteServiceProcessRequest request,
  ) async {
    try {
      final response = await _dio.patch(
        '/service-of-process/$id/complete',
        data: request.toJson(),
      );
      return Right(
        ServiceProcess.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (error) {
      return Left(mapDioError(error));
    }
  }

  @override
  ApiResult<void> cancel(String id) async {
    try {
      await _dio.delete('/service-of-process/$id');
      return const Right(null);
    } on DioException catch (error) {
      return Left(mapDioError(error));
    }
  }
}
