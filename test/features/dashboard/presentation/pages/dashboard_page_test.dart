import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/authentication/presentation/bloc/session_cubit.dart';
import 'package:hqooq/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:hqooq/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:hqooq/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:hqooq/features/tasks/domain/entities/task_item.dart';
import 'package:hqooq/features/tasks/domain/entities/task_priority.dart';
import 'package:hqooq/features/tasks/domain/entities/task_status.dart';
import 'package:mocktail/mocktail.dart';

class MockDashboardBloc extends MockBloc<DashboardEvent, DashboardState>
    implements DashboardBloc {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

/// Preloaded synchronously — see case_details_page_test.dart / CLAUDE.md for
/// why the real JSON delegate's async load is flaky across multiple
/// testWidgets blocks in one file.
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
  late MockDashboardBloc bloc;
  late MockSessionCubit sessionCubit;

  final user = User(
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

  const metrics = DashboardMetrics(
    totalActiveCases: 14,
    pendingTasks: 1,
    upcomingHearings: 3,
  );

  final task = TaskItem(
    id: 't1',
    assignedById: 'u2',
    assignedToId: 'u1',
    title: 'File motion for Hernandez case',
    priority: TaskPriority.high,
    status: TaskStatus.pending,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUpAll(() async {
    preloadedEn = AppLocalizations(const Locale('en'));
    await preloadedEn.load();
  });

  setUp(() async {
    await getIt.reset();
    bloc = MockDashboardBloc();
    sessionCubit = MockSessionCubit();
    getIt.registerFactory<DashboardBloc>(() => bloc);
    getIt.registerSingleton<SessionCubit>(sessionCubit);
    when(
      () => sessionCubit.state,
    ).thenReturn(SessionAuthenticated(user, isFirmAdmin: false));
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildTestable() {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: [
        _PreloadedAppLocalizationsDelegate(preloadedEn),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: const DashboardPage(),
    );
  }

  testWidgets('shows a loading spinner while DashboardLoading', (tester) async {
    whenListen(
      bloc,
      const Stream<DashboardState>.empty(),
      initialState: DashboardLoading(),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the error view on DashboardError', (tester) async {
    whenListen(
      bloc,
      const Stream<DashboardState>.empty(),
      initialState: const DashboardError('Server error'),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('Server error'), findsOneWidget);
  });

  testWidgets(
    'renders real metrics and the personal pending-tasks list on DashboardLoaded',
    (tester) async {
      whenListen(
        bloc,
        const Stream<DashboardState>.empty(),
        initialState: DashboardLoaded(metrics, [task]),
      );

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      expect(find.text('14'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('File motion for Hernandez case'), findsOneWidget);
    },
  );

  testWidgets('shows the empty state when there are no pending tasks', (
    tester,
  ) async {
    whenListen(
      bloc,
      const Stream<DashboardState>.empty(),
      initialState: const DashboardLoaded(metrics, []),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('No pending tasks'), findsOneWidget);
  });
}
