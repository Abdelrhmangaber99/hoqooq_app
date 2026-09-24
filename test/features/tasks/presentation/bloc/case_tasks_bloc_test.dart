import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/tasks/domain/entities/task_item.dart';
import 'package:hqooq/features/tasks/domain/entities/task_priority.dart';
import 'package:hqooq/features/tasks/domain/entities/task_status.dart';
import 'package:hqooq/features/tasks/domain/repository/i_task_repository.dart';
import 'package:hqooq/features/tasks/presentation/bloc/case_tasks_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockTaskRepository extends Mock implements ITaskRepository {}

void main() {
  late MockTaskRepository repository;

  TaskItem task({
    String caseId = 'c1',
    TaskStatus status = TaskStatus.newTask,
  }) => TaskItem(
    id: 't1',
    caseId: caseId,
    assignedById: 'u1',
    assignedToId: 'u2',
    title: 'File motion',
    priority: TaskPriority.normal,
    status: status,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() => repository = MockTaskRepository());

  blocTest<CaseTasksBloc, CaseTasksState>(
    'loads only tasks belonging to the requested case',
    build: () {
      when(
        () => repository.getTasks(),
      ).thenAnswer((_) async => Right([task(), task(caseId: 'c2')]));
      return CaseTasksBloc(repository);
    },
    act: (bloc) => bloc.add(const FetchCaseTasksRequested('c1')),
    expect: () => [
      isA<CaseTasksLoading>(),
      isA<CaseTasksLoaded>().having((state) => state.items.length, 'length', 1),
    ],
  );

  blocTest<CaseTasksBloc, CaseTasksState>(
    'completes with the dedicated note contract and refreshes',
    seed: () => CaseTasksLoaded([task()]),
    build: () {
      when(
        () => repository.completeTask('t1', 'Work finished'),
      ).thenAnswer((_) async => Right(task(status: TaskStatus.completed)));
      when(
        () => repository.getTasks(),
      ).thenAnswer((_) async => Right([task(status: TaskStatus.completed)]));
      return CaseTasksBloc(repository);
    },
    act: (bloc) => bloc.add(
      const CompleteTaskRequested(
        id: 't1',
        caseId: 'c1',
        completionNote: 'Work finished',
      ),
    ),
    expect: () => [
      isA<CaseTasksLoaded>().having(
        (state) => state.actionId,
        'actionId',
        't1',
      ),
      isA<CaseTasksLoaded>().having(
        (state) => state.items.single.status,
        'status',
        TaskStatus.completed,
      ),
    ],
  );

  blocTest<CaseTasksBloc, CaseTasksState>(
    'cancels through the retained workflow and refreshes',
    seed: () => CaseTasksLoaded([task()]),
    build: () {
      when(
        () => repository.cancelTask('t1'),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => repository.getTasks(),
      ).thenAnswer((_) async => Right([task(status: TaskStatus.cancelled)]));
      return CaseTasksBloc(repository);
    },
    act: (bloc) => bloc.add(const CancelTaskRequested(id: 't1', caseId: 'c1')),
    expect: () => [
      isA<CaseTasksLoaded>().having(
        (state) => state.actionId,
        'actionId',
        't1',
      ),
      isA<CaseTasksLoaded>().having(
        (state) => state.items.single.status,
        'status',
        TaskStatus.cancelled,
      ),
    ],
  );
}
