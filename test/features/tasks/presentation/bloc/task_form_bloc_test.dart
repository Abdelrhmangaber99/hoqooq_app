import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/cases/domain/entities/case_party_snapshot.dart';
import 'package:hqooq/features/cases/domain/entities/case_priority.dart';
import 'package:hqooq/features/cases/domain/entities/case_status.dart';
import 'package:hqooq/features/cases/domain/entities/legal_case.dart';
import 'package:hqooq/features/cases/domain/repository/i_case_repository.dart';
import 'package:hqooq/features/tasks/data/models/create_task_request.dart';
import 'package:hqooq/features/tasks/data/models/update_task_request.dart';
import 'package:hqooq/features/tasks/domain/entities/task_item.dart';
import 'package:hqooq/features/tasks/domain/entities/task_priority.dart';
import 'package:hqooq/features/tasks/domain/entities/task_status.dart';
import 'package:hqooq/features/tasks/domain/repository/i_task_repository.dart';
import 'package:hqooq/features/tasks/presentation/bloc/task_form_bloc.dart';
import 'package:hqooq/features/users/domain/repository/i_user_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockTaskRepository extends Mock implements ITaskRepository {}

class MockUserRepository extends Mock implements IUserRepository {}

class MockCaseRepository extends Mock implements ICaseRepository {}

void main() {
  late MockTaskRepository taskRepository;
  late MockUserRepository userRepository;
  late MockCaseRepository caseRepository;

  final user = User(
    id: 'u1',
    email: 'lawyer@firm.com',
    fullName: 'Jane Doe',
    status: 'ACTIVE',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    tenant: const TenantRef(id: 't1', name: 'Reynolds & Associates'),
  );

  final legalCase = LegalCase(
    id: 'c1',
    tenantId: 't1',
    caseNumber: 'CASE-2026-00001',
    status: CaseStatus.active,
    caseTypeId: 'ct1',
    priority: CasePriority.high,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    clientSnapshot: const CaseClientSnapshot(
      id: 'cl1',
      clientType: 'INDIVIDUAL',
      name: 'Carlos Hernandez',
    ),
    team: const [],
  );

  final task = TaskItem(
    id: 't1',
    assignedById: 'u1',
    assignedToId: 'u1',
    title: 'File motion',
    priority: TaskPriority.normal,
    status: TaskStatus.newTask,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(
      const CreateTaskRequest(caseId: '', assignedToId: '', title: ''),
    );
    registerFallbackValue(const UpdateTaskRequest());
  });

  setUp(() {
    taskRepository = MockTaskRepository();
    userRepository = MockUserRepository();
    caseRepository = MockCaseRepository();
  });

  TaskFormBloc buildBloc() =>
      TaskFormBloc(taskRepository, userRepository, caseRepository);

  blocTest<TaskFormBloc, TaskFormState>(
    'emits [Loading, Ready] with users/cases on LoadTaskFormReferenceDataRequested',
    build: () {
      when(
        () => userRepository.getAssignableUsers(),
      ).thenAnswer((_) async => Right([user]));
      when(
        () => caseRepository.getCases(),
      ).thenAnswer((_) async => Right([legalCase]));
      return buildBloc();
    },
    act: (bloc) => bloc.add(LoadTaskFormReferenceDataRequested()),
    expect: () => [
      isA<TaskFormLoading>(),
      TaskFormReady(users: [user], cases: [legalCase]),
    ],
  );

  blocTest<TaskFormBloc, TaskFormState>(
    'degrades to empty lists (not a screen failure) when users/cases fail',
    build: () {
      when(
        () => userRepository.getAssignableUsers(),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      when(
        () => caseRepository.getCases(),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return buildBloc();
    },
    act: (bloc) => bloc.add(LoadTaskFormReferenceDataRequested()),
    expect: () => [
      isA<TaskFormLoading>(),
      const TaskFormReady(users: [], cases: []),
    ],
  );

  blocTest<TaskFormBloc, TaskFormState>(
    'emits [Ready(submitting), Success] on a successful create',
    build: () {
      when(
        () => userRepository.getAssignableUsers(),
      ).thenAnswer((_) async => Right([user]));
      when(
        () => caseRepository.getCases(),
      ).thenAnswer((_) async => Right([legalCase]));
      when(
        () => taskRepository.createTask(any()),
      ).thenAnswer((_) async => Right(task));
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(LoadTaskFormReferenceDataRequested());
      await Future.delayed(Duration.zero);
      bloc.add(
        const CreateTaskSubmitted(
          CreateTaskRequest(
            caseId: 'c1',
            assignedToId: 'u1',
            title: 'File motion',
          ),
        ),
      );
    },
    expect: () => [
      isA<TaskFormLoading>(),
      TaskFormReady(users: [user], cases: [legalCase]),
      TaskFormReady(users: [user], cases: [legalCase], isSubmitting: true),
      TaskFormSuccess(task),
    ],
  );

  blocTest<TaskFormBloc, TaskFormState>(
    'emits [Ready(submitting), Success] on a successful update',
    build: () {
      when(
        () => userRepository.getAssignableUsers(),
      ).thenAnswer((_) async => Right([user]));
      when(
        () => caseRepository.getCases(),
      ).thenAnswer((_) async => Right([legalCase]));
      when(
        () => taskRepository.updateTask('t1', any()),
      ).thenAnswer((_) async => Right(task));
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(LoadTaskFormReferenceDataRequested());
      await Future.delayed(Duration.zero);
      bloc.add(
        const UpdateTaskSubmitted(
          't1',
          UpdateTaskRequest(status: TaskStatus.inProgress),
        ),
      );
    },
    expect: () => [
      isA<TaskFormLoading>(),
      TaskFormReady(users: [user], cases: [legalCase]),
      TaskFormReady(users: [user], cases: [legalCase], isSubmitting: true),
      TaskFormSuccess(task),
    ],
  );
}
