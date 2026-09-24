import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/tasks/data/models/create_task_request.dart';
import 'package:hqooq/features/tasks/data/models/update_task_request.dart';
import 'package:hqooq/features/tasks/data/repository/task_repository.dart';
import 'package:hqooq/features/tasks/domain/entities/task_priority.dart';
import 'package:hqooq/features/tasks/domain/entities/task_status.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late TaskRepository repository;

  setUp(() {
    dio = MockDio();
    repository = TaskRepository(dio);
  });

  Response<T> okResponse<T>(String path, T data) {
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: data,
      statusCode: 200,
    );
  }

  Map<String, dynamic> userJson(String id, String fullName) => {
    'id': id,
    'email': '$id@firm.com',
    'fullName': fullName,
    'isSuperAdmin': false,
    'status': 'ACTIVE',
    'mfaEnabled': false,
    'createdAt': '2026-01-01T00:00:00.000Z',
    'updatedAt': '2026-01-01T00:00:00.000Z',
    'roles': <Map<String, dynamic>>[],
    'tenant': {'id': 't1', 'name': 'Reynolds & Associates'},
  };

  // Real shape confirmed from source: TasksService.findAll loads
  // relations: ['case', 'assignedTo', 'assignedBy'] -- all three nested.
  Map<String, dynamic> taskJson({
    String status = 'NEW',
    String priority = 'HIGH',
  }) {
    return {
      'id': 't1',
      'caseId': 'c1',
      'case': {
        'id': 'c1',
        'tenantId': 't1',
        'caseNumber': 'CASE-2026-00001',
        'status': 'ACTIVE',
        'clientId': 'cl1',
        'caseTypeId': 'ct1',
        'priority': 'HIGH',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'updatedAt': '2026-01-01T00:00:00.000Z',
      },
      'assignedById': 'u1',
      'assignedBy': userJson('u1', 'Jane Doe'),
      'assignedToId': 'u2',
      'assignedTo': userJson('u2', 'John Roe'),
      'title': 'File motion',
      'priority': priority,
      'status': status,
      'dueDate': '2026-02-01T00:00:00.000Z',
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-01T00:00:00.000Z',
    };
  }

  group('getTasks', () {
    test('GETs /tasks and parses the full shape', () async {
      when(
        () => dio.get('/tasks'),
      ).thenAnswer((_) async => okResponse('/tasks', [taskJson()]));

      final result = await repository.getTasks();

      verify(() => dio.get('/tasks')).called(1);
      result.fold((_) => fail('expected Right'), (tasks) {
        expect(tasks, hasLength(1));
        expect(tasks.first.title, 'File motion');
        expect(tasks.first.assignedTo?.fullName, 'John Roe');
        expect(tasks.first.assignedBy?.fullName, 'Jane Doe');
        expect(tasks.first.caseSummary?.caseNumber, 'CASE-2026-00001');
        expect(tasks.first.status, TaskStatus.newTask);
        expect(tasks.first.priority, TaskPriority.high);
      });
    });

    test('falls back to unknown for an unrecognized status/priority', () async {
      when(() => dio.get('/tasks')).thenAnswer(
        (_) async => okResponse('/tasks', [
          taskJson(status: 'SOMETHING_NEW', priority: 'SOMETHING_ELSE'),
        ]),
      );

      final result = await repository.getTasks();

      result.fold((_) => fail('expected Right'), (tasks) {
        expect(tasks.first.status, TaskStatus.unknown);
        expect(tasks.first.priority, TaskPriority.unknown);
      });
    });

    test('maps a server error to ServerFailure', () async {
      when(() => dio.get('/tasks')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/tasks'),
          response: Response(
            requestOptions: RequestOptions(path: '/tasks'),
            statusCode: 500,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await repository.getTasks();

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('createTask', () {
    test('POSTs /tasks with the full request body', () async {
      when(
        () => dio.post('/tasks', data: any(named: 'data')),
      ).thenAnswer((_) async => okResponse('/tasks', taskJson()));

      const request = CreateTaskRequest(
        caseId: 'c1',
        assignedToId: 'u2',
        title: 'File motion',
      );
      await repository.createTask(request);

      final captured = verify(
        () => dio.post('/tasks', data: captureAny(named: 'data')),
      ).captured;
      final body = captured.single as Map<String, dynamic>;
      // CreateTaskRequest is not partial like the Update*Request models --
      // unset optional fields are sent as explicit null, which
      // CreateTaskDto's @IsOptional() fields tolerate fine (whitelist only
      // rejects undeclared keys, not null values for declared ones).
      expect(body, {
        'caseId': 'c1',
        'assignedToId': 'u2',
        'title': 'File motion',
        'description': null,
        'priority': null,
        'status': null,
        'dueDate': null,
        'linkedEntityType': null,
        'linkedEntityId': null,
      });
    });

    test('maps a 400 to ValidationFailure', () async {
      when(() => dio.post('/tasks', data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/tasks'),
          response: Response(
            requestOptions: RequestOptions(path: '/tasks'),
            statusCode: 400,
            data: {'message': 'title should not be empty'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      const request = CreateTaskRequest(
        caseId: 'c1',
        assignedToId: 'u2',
        title: '',
      );
      final result = await repository.createTask(request);

      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('updateTask', () {
    test('PATCHes /tasks/{id} with only the changed fields', () async {
      when(
        () => dio.patch('/tasks/t1', data: any(named: 'data')),
      ).thenAnswer((_) async => okResponse('/tasks/t1', taskJson()));

      const request = UpdateTaskRequest(status: TaskStatus.inProgress);
      await repository.updateTask('t1', request);

      final captured = verify(
        () => dio.patch('/tasks/t1', data: captureAny(named: 'data')),
      ).captured;
      final body = captured.single as Map<String, dynamic>;
      expect(body, {'status': 'IN_PROGRESS'});
    });
  });

  group('completeTask', () {
    test('PATCHes the dedicated completion endpoint with a note', () async {
      when(
        () => dio.patch('/tasks/t1/complete', data: any(named: 'data')),
      ).thenAnswer(
        (_) async =>
            okResponse('/tasks/t1/complete', taskJson(status: 'COMPLETED')),
      );

      await repository.completeTask('t1', 'Filed and confirmed');

      verify(
        () => dio.patch(
          '/tasks/t1/complete',
          data: {'completionNote': 'Filed and confirmed'},
        ),
      ).called(1);
    });
  });

  group('cancelTask', () {
    test('DELETEs the retained-cancellation endpoint', () async {
      when(() => dio.delete('/tasks/t1')).thenAnswer(
        (_) async => Response<void>(
          requestOptions: RequestOptions(path: '/tasks/t1'),
          statusCode: 204,
        ),
      );

      final result = await repository.cancelTask('t1');

      expect(result.isRight(), isTrue);
      verify(() => dio.delete('/tasks/t1')).called(1);
    });
  });
}
