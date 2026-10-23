import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hqooq/core/auth/permission_codes.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/authentication/presentation/bloc/session_cubit.dart';
import 'package:hqooq/features/tasks/data/models/update_task_request.dart';
import 'package:hqooq/features/tasks/domain/entities/task_item.dart';
import 'package:hqooq/features/tasks/domain/entities/task_priority.dart';
import 'package:hqooq/features/tasks/domain/entities/task_status.dart';
import 'package:hqooq/features/tasks/domain/repository/i_task_repository.dart';
import 'package:hqooq/features/tasks/presentation/pages/task_details_page.dart';
import 'package:mocktail/mocktail.dart';

class MockTaskRepository extends Mock implements ITaskRepository {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

/// Preloaded synchronously — the real JSON delegate's async load is flaky
/// across multiple `testWidgets` blocks in one file (see CLAUDE.md).
class _PreloadedAppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _PreloadedAppLocalizationsDelegate(this._instance);
  final AppLocalizations _instance;

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<AppLocalizations> load(Locale locale) => SynchronousFuture(_instance);

  @override
  bool shouldReload(_PreloadedAppLocalizationsDelegate old) => false;
}

void main() {
  late AppLocalizations preloadedEn;
  late MockTaskRepository repository;
  late MockSessionCubit sessionCubit;

  User userWith(List<String> permissions, {String accountType = 'EMPLOYEE'}) =>
      User(
        id: 'u1',
        email: 'lawyer@firm.com',
        fullName: 'Jane Doe',
        status: 'ACTIVE',
        accountType: accountType,
        permissions: permissions,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        tenant: const TenantRef(id: 't1', name: 'Reynolds & Associates'),
      );

  TaskItem buildTask({TaskStatus status = TaskStatus.newTask}) => TaskItem(
    id: 't1',
    assignedById: 'u1',
    assignedToId: 'u1',
    title: 'File motion',
    priority: TaskPriority.high,
    status: status,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUpAll(() async {
    preloadedEn = AppLocalizations(const Locale('en'));
    await preloadedEn.load();
    registerFallbackValue(UpdateTaskRequest(status: TaskStatus.inProgress));
  });

  setUp(() async {
    await getIt.reset();
    repository = MockTaskRepository();
    sessionCubit = MockSessionCubit();
    getIt.registerFactory<ITaskRepository>(() => repository);
    getIt.registerSingleton<SessionCubit>(sessionCubit);
  });

  tearDown(() async {
    await getIt.reset();
  });

  void stubSession(User user, {bool isFirmAdmin = false}) {
    when(
      () => sessionCubit.state,
    ).thenReturn(SessionAuthenticated(user, isFirmAdmin: isFirmAdmin));
  }

  Widget buildTestable(TaskItem task) {
    final router = GoRouter(
      initialLocation: '/task',
      routes: [
        GoRoute(
          path: '/task',
          builder: (context, state) => TaskDetailsPage(task: task),
        ),
      ],
    );
    return MaterialApp.router(
      routerConfig: router,
      locale: const Locale('en'),
      localizationsDelegates: [
        _PreloadedAppLocalizationsDelegate(preloadedEn),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
    );
  }

  testWidgets('renders the task and offers no actions without a task code', (
    tester,
  ) async {
    stubSession(userWith(const []));

    await tester.pumpWidget(buildTestable(buildTask()));
    await tester.pumpAndSettle();

    expect(find.text('Task Details'), findsOneWidget);
    expect(find.text('File motion'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
    expect(find.text('Complete Task'), findsNothing);
    expect(find.text('Cancel Task'), findsNothing);
    expect(find.text('Change status'), findsNothing);
  });

  testWidgets('a task.complete holder can complete and cancel, but cannot '
      'change status', (tester) async {
    stubSession(userWith(const [PermissionCodes.taskComplete]));

    await tester.pumpWidget(buildTestable(buildTask()));
    await tester.pumpAndSettle();

    expect(find.text('Complete Task'), findsOneWidget);
    expect(find.text('Cancel Task'), findsOneWidget);
    expect(find.text('Change status'), findsNothing);
  });

  testWidgets('a task.update holder can change status but cannot complete or '
      'cancel', (tester) async {
    stubSession(userWith(const [PermissionCodes.taskUpdate]));

    await tester.pumpWidget(buildTestable(buildTask()));
    await tester.pumpAndSettle();

    expect(find.text('Change status'), findsOneWidget);
    // Exactly one chip: only statuses other than the current one are offered,
    // so the task's own `New` status is a badge, never a button. (The backend
    // rejects COMPLETED through this route, hence no `Completed` chip either.)
    expect(find.byType(ActionChip), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('Complete Task'), findsNothing);
    expect(find.text('Cancel Task'), findsNothing);
  });

  testWidgets('a Firm Admin sees every task action without explicit grants', (
    tester,
  ) async {
    stubSession(
      userWith(const [], accountType: 'FIRM_ADMIN'),
      isFirmAdmin: true,
    );

    await tester.pumpWidget(buildTestable(buildTask()));
    await tester.pumpAndSettle();

    expect(find.text('Change status'), findsOneWidget);
    expect(find.text('Complete Task'), findsOneWidget);
    expect(find.text('Cancel Task'), findsOneWidget);
  });

  testWidgets('a completed task offers no further actions', (tester) async {
    stubSession(
      userWith(const [], accountType: 'FIRM_ADMIN'),
      isFirmAdmin: true,
    );

    await tester.pumpWidget(
      buildTestable(buildTask(status: TaskStatus.completed)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Complete Task'), findsNothing);
    expect(find.text('Cancel Task'), findsNothing);
  });

  testWidgets('completing requires a note and posts it to the complete route', (
    tester,
  ) async {
    stubSession(userWith(const [PermissionCodes.taskComplete]));
    when(
      () => repository.completeTask(any(), any()),
    ).thenAnswer((_) async => Right(buildTask(status: TaskStatus.completed)));

    await tester.pumpWidget(buildTestable(buildTask()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Complete Task'));
    await tester.pumpAndSettle();

    // The note field is revealed, and Confirm is available.
    expect(find.text('COMPLETION NOTE'), findsOneWidget);

    // An empty note must not reach the API — `CompleteTaskDto.completionNote`
    // is required server-side.
    await tester.tap(find.text('Confirm'));
    await tester.pump();
    verifyNever(() => repository.completeTask(any(), any()));

    await tester.enterText(find.byType(TextFormField), 'Served the motion');
    await tester.pump();
    await tester.tap(find.text('Confirm'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    verify(() => repository.completeTask('t1', 'Served the motion')).called(1);
    expect(find.text('Completed'), findsOneWidget);
  });

  testWidgets('cancelling asks for confirmation, then cancels', (tester) async {
    stubSession(userWith(const [PermissionCodes.taskComplete]));
    when(
      () => repository.cancelTask(any()),
    ).thenAnswer((_) async => const Right(null));

    await tester.pumpWidget(buildTestable(buildTask()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel Task'));
    await tester.pumpAndSettle();

    expect(
      find.text('Cancel this task while retaining its history?'),
      findsOneWidget,
    );

    await tester.tap(find.text('Confirm'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    verify(() => repository.cancelTask('t1')).called(1);
    expect(find.text('Cancelled'), findsOneWidget);
  });

  testWidgets('changing status patches the task', (tester) async {
    stubSession(userWith(const [PermissionCodes.taskUpdate]));
    when(
      () => repository.updateTask(any(), any()),
    ).thenAnswer((_) async => Right(buildTask(status: TaskStatus.inProgress)));

    await tester.pumpWidget(buildTestable(buildTask()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('In Progress'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    verify(
      () => repository.updateTask('t1', any(that: isA<UpdateTaskRequest>())),
    ).called(1);
    expect(find.text('In Progress'), findsOneWidget);
  });

  testWidgets('surfaces a failure message instead of a success state', (
    tester,
  ) async {
    stubSession(userWith(const [PermissionCodes.taskComplete]));
    when(
      () => repository.completeTask(any(), any()),
    ).thenAnswer((_) async => const Left(ValidationFailure('note required')));

    await tester.pumpWidget(buildTestable(buildTask()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Complete Task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'x');
    await tester.pump();
    await tester.tap(find.text('Confirm'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Still incomplete, and the backend sentence is on screen.
    expect(find.text('New'), findsOneWidget);
    expect(find.text('note required'), findsWidgets);
  });

  testWidgets('does not expose a raw generic 500 message inline', (
    tester,
  ) async {
    stubSession(userWith(const [PermissionCodes.taskComplete]));
    when(() => repository.completeTask(any(), any())).thenAnswer(
      (_) async => const Left(ServerFailure('Internal server error')),
    );

    await tester.pumpWidget(buildTestable(buildTask()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Complete Task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Work completed');
    await tester.pump();
    await tester.tap(find.text('Confirm'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Server error occurred'), findsWidgets);
    expect(find.text('Internal server error'), findsNothing);
  });
}
