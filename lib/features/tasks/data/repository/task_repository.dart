import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
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
}
