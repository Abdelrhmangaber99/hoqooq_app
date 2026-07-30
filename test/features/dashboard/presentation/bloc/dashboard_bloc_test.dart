import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/authentication/presentation/bloc/session_cubit.dart';
import 'package:hqooq/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:hqooq/features/dashboard/domain/repository/i_dashboard_repository.dart';
import 'package:hqooq/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:hqooq/features/tasks/domain/entities/task_item.dart';
import 'package:hqooq/features/tasks/domain/entities/task_priority.dart';
import 'package:hqooq/features/tasks/domain/entities/task_status.dart';
import 'package:hqooq/features/tasks/domain/repository/i_task_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockDashboardRepository extends Mock implements IDashboardRepository {}

class MockTaskRepository extends Mock implements ITaskRepository {}

void main() {
  late MockDashboardRepository dashboardRepository;
  late MockTaskRepository taskRepository;
  late SessionCubit sessionCubit;

  const metrics = DashboardMetrics(
    totalActiveCases: 14,
    pendingTasks: 2,
    upcomingHearings: 3,
  );

  final currentUser = User(
    id: 'u1',
    email: 'lawyer@firm.com',
    fullName: 'Jane Doe',
    isSuperAdmin: false,
    status: 'ACTIVE',
    mfaEnabled: false,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    roles: const [],
    tenant: const TenantRef(id: 't1', name: 'Reynolds & Associates'),
  );

  TaskItem buildTask({
    required String id,
    required String assignedToId,
    TaskStatus status = TaskStatus.pending,
  }) {
    return TaskItem(
      id: id,
      assignedById: 'u2',
      assignedToId: assignedToId,
      title: 'Task $id',
      priority: TaskPriority.normal,
      status: status,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  }

  setUp(() {
    dashboardRepository = MockDashboardRepository();
    taskRepository = MockTaskRepository();
    sessionCubit = SessionCubit();
  });

  DashboardBloc buildBloc() =>
      DashboardBloc(dashboardRepository, taskRepository, sessionCubit);

  final myPendingTask = buildTask(id: 't1', assignedToId: 'u1');
  final myCompletedTask = buildTask(
    id: 't2',
    assignedToId: 'u1',
    status: TaskStatus.completed,
  );
  final someoneElsesTask = buildTask(id: 't3', assignedToId: 'u2');

  blocTest<DashboardBloc, DashboardState>(
    'emits [Loading, Loaded] with metrics and only the current user\'s '
    'pending/in-progress tasks',
    build: () {
      sessionCubit.authenticated(currentUser, 'token', isFirmAdmin: false);
      when(
        () => dashboardRepository.getMetrics(),
      ).thenAnswer((_) async => const Right(metrics));
      when(() => taskRepository.getTasks()).thenAnswer(
        (_) async => Right([myPendingTask, myCompletedTask, someoneElsesTask]),
      );
      return buildBloc();
    },
    act: (bloc) => bloc.add(FetchDashboardRequested()),
    expect: () => [
      isA<DashboardLoading>(),
      DashboardLoaded(metrics, [myPendingTask]),
    ],
  );

  blocTest<DashboardBloc, DashboardState>(
    'emits [Loading, Error] when the metrics fetch fails',
    build: () {
      sessionCubit.authenticated(currentUser, 'token', isFirmAdmin: false);
      when(
        () => dashboardRepository.getMetrics(),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return buildBloc();
    },
    act: (bloc) => bloc.add(FetchDashboardRequested()),
    expect: () => [isA<DashboardLoading>(), isA<DashboardError>()],
    verify: (_) {
      verifyNever(() => taskRepository.getTasks());
    },
  );

  blocTest<DashboardBloc, DashboardState>(
    'shows an empty pending-tasks list (not a screen failure) when the '
    'secondary tasks fetch fails',
    build: () {
      sessionCubit.authenticated(currentUser, 'token', isFirmAdmin: false);
      when(
        () => dashboardRepository.getMetrics(),
      ).thenAnswer((_) async => const Right(metrics));
      when(
        () => taskRepository.getTasks(),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return buildBloc();
    },
    act: (bloc) => bloc.add(FetchDashboardRequested()),
    expect: () => [isA<DashboardLoading>(), const DashboardLoaded(metrics, [])],
  );
}
