import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/task_item.dart';
import '../../domain/repository/i_task_repository.dart';
import '../models/create_task_request.dart';
import '../models/update_task_request.dart';

/// Real implementation of [ITaskRepository] against `GET /tasks`.
@LazySingleton(as: ITaskRepository)
class TaskRepository implements ITaskRepository {
  TaskRepository(this._dio);

  final Dio _dio;

  @override
  ApiResult<List<TaskItem>> getTasks() async {
    try {
      final response = await _dio.get('/tasks');
      final data = response.data as List<dynamic>;
      return Right(
        data
            .map((json) => TaskItem.fromJson(json as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    } catch (_) {
      // A payload that doesn't match the entity shape must fail as an
      // `ApiResult`, never as a thrown exception: an uncaught decode error
      // escapes the calling bloc's event handler before it can emit, which
      // pins the screen on its loading spinner instead of showing an error.
      return const Left(ServerFailure());
    }
  }

  @override
  ApiResult<TaskItem> createTask(CreateTaskRequest request) async {
    try {
      final response = await _dio.post('/tasks', data: request.toJson());
      return Right(TaskItem.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<TaskItem> updateTask(String id, UpdateTaskRequest request) async {
    try {
      final response = await _dio.patch('/tasks/$id', data: request.toJson());
      return Right(TaskItem.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<TaskItem> completeTask(String id, String completionNote) async {
    try {
      final response = await _dio.patch(
        '/tasks/$id/complete',
        data: {'completionNote': completionNote},
      );
      return Right(TaskItem.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<void> cancelTask(String id) async {
    try {
      await _dio.delete('/tasks/$id');
      return const Right(null);
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
