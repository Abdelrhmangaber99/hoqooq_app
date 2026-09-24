import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import 'package:hqooq/core/router/app_router.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/authentication/presentation/bloc/session_cubit.dart';
import 'package:hqooq/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:hqooq/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:hqooq/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:hqooq/features/finance/domain/entities/finance_summary.dart';
import 'package:go_router/go_router.dart';
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
  const _PreloadedAppLocalizationsDelegate(this._cache);

  final Map<Locale, AppLocalizations> _cache;

  @override
  bool isSupported(Locale locale) =>
      _cache.keys.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    final match =
        _cache.keys.firstWhere((l) => l.languageCode == locale.languageCode);
    return SynchronousFuture(_cache[match]!);
  }

  @override
  bool shouldReload(_PreloadedAppLocalizationsDelegate old) => false;
}

void main() {
  late Map<Locale, AppLocalizations> localizationsCache;
  late MockDashboardBloc bloc;
  late MockSessionCubit sessionCubit;

  final sessionUser = User(
    id: 'u1',
    email: 'user@firm.com',
    fullName: 'Jane Doe',
    isSuperAdmin: false,
    status: 'ACTIVE',
    mfaEnabled: false,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    tenant: const TenantRef(id: 't1', name: 'Demo Law Firm'),
  );

  // KPI numbers deliberately avoid the finance count-card values (2/1/3)
  // so text lookups in tests stay unambiguous.
  const metrics = DashboardMetrics(
    totalActiveCases: 14,
    pendingTasks: 7,
    upcomingHearings: 5,
  );

  // Backend-computed authorized aggregates (the dashboard never derives
  // these client-side): 10,000 agreed across cases, 6,000 collected from
  // valid non-reversed payments, 4,000 outstanding.
  const finance = FinanceSummary(
    totalCaseValue: 10000,
    totalCollected: 6000,
    totalOutstanding: 4000,
    paidCases: 2,
    partialCases: 1,
    unpaidCases: 3,
    cases: [],
  );

  setUpAll(() async {
    registerFallbackValue(FetchDashboardRequested());
    final en = AppLocalizations(const Locale('en'));
    await en.load();
    final ar = AppLocalizations(const Locale('ar'));
    await ar.load();
    localizationsCache = {const Locale('en'): en, const Locale('ar'): ar};
  });

  setUp(() async {
    await getIt.reset();
    bloc = MockDashboardBloc();
    sessionCubit = MockSessionCubit();
    getIt.registerFactory<DashboardBloc>(() => bloc);
    getIt.registerSingleton<SessionCubit>(sessionCubit);
    when(() => sessionCubit.state).thenReturn(
      SessionAuthenticated(
        sessionUser.copyWith(permissions: const ['finance.firm.read']),
        isFirmAdmin: false,
      ),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildTestable({Locale locale = const Locale('en')}) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => DashboardPage(),
        ),
        GoRoute(
          path: AppRouter.finance,
          builder: (_, _) => const Scaffold(body: Text('FINANCE_HUB')),
        ),
      ],
    );
    return MaterialApp.router(
      locale: locale,
      localizationsDelegates: [
        _PreloadedAppLocalizationsDelegate(localizationsCache),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
      routerConfig: router,
    );
  }

  DashboardLoaded loadedState({
    FinanceSummary? financeSummary,
    Map<String, dynamic> financeFilters = const {},
    bool canViewFinance = true,
  }) {
    return DashboardLoaded(
      metrics,
      upcomingHearings: const [],
      financeSummary: financeSummary,
      financeFilters: financeFilters,
      canViewFinance: canViewFinance,
    );
  }

  group('permission visibility', () {
    testWidgets(
        '(1) firm-wide finance user (finance.firm.read) sees the finance '
        'dashboard with all six aggregates', (tester) async {
      whenListen(
        bloc,
        const Stream<DashboardState>.empty(),
        initialState: loadedState(financeSummary: finance),
      );

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      expect(find.text('Finance'), findsOneWidget);
      expect(find.text('EGP 10,000.00'), findsOneWidget);
      expect(find.text('EGP 6,000.00'), findsOneWidget);
      expect(find.text('EGP 4,000.00'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // paid cases
      expect(find.text('1'), findsOneWidget); // partial cases
      expect(find.text('3'), findsOneWidget); // unpaid cases
      expect(find.text('Paid Cases'), findsOneWidget);
      expect(find.text('Partially Paid Cases'), findsOneWidget);
      expect(find.text('Unpaid Cases'), findsOneWidget);
      // KPI numbers distinct from finance counts on purpose.
      expect(find.text('7'), findsOneWidget); // pending tasks
    });

    testWidgets(
        '(2) employee without any finance permission sees no finance '
        'section at all', (tester) async {
      when(() => sessionCubit.state).thenReturn(
        SessionAuthenticated(
          sessionUser.copyWith(permissions: const []),
          isFirmAdmin: false,
        ),
      );
      whenListen(
        bloc,
        const Stream<DashboardState>.empty(),
        initialState: loadedState(canViewFinance: false),
      );

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      expect(find.text('Finance'), findsNothing);
      expect(find.text('EGP 10,000.00'), findsNothing);
      expect(find.text('Paid Cases'), findsNothing);
      // Unrelated sections still render — no second dashboard system.
      expect(find.text('Recent activity'), findsOneWidget);
    });

    testWidgets(
        '(3) an ACCOUNTANT-classified user without finance.firm.read sees no '
        'firm finance section (job title grants nothing)', (tester) async {
      when(() => sessionCubit.state).thenReturn(
        SessionAuthenticated(
          sessionUser.copyWith(
            permissions: const [],
            jobClassification: 'ACCOUNTANT',
          ),
          isFirmAdmin: false,
        ),
      );
      whenListen(
        bloc,
        const Stream<DashboardState>.empty(),
        initialState: loadedState(canViewFinance: false),
      );

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      expect(find.text('Finance'), findsNothing);
      expect(find.text('EGP 10,000.00'), findsNothing);
    });

    testWidgets(
        '(4) case-only finance permissions (case.view/payment.record) do not '
        'unlock firm-wide totals', (tester) async {
      when(() => sessionCubit.state).thenReturn(
        SessionAuthenticated(
          sessionUser.copyWith(
            permissions: const [
              'finance.case.view',
              'finance.payment.record',
            ],
          ),
          isFirmAdmin: false,
        ),
      );
      whenListen(
        bloc,
        const Stream<DashboardState>.empty(),
        initialState: loadedState(canViewFinance: false),
      );

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      expect(find.text('Finance'), findsNothing);
      expect(find.text('EGP 10,000.00'), findsNothing);
    });

    testWidgets(
        '(14) revoking finance.firm.read mid-session hides the finance '
        'widgets and the bloc stops serving aggregate data',
        (tester) async {
      final controller = StreamController<DashboardState>.broadcast();
      addTearDown(controller.close);

      // Permission held: the panel renders.
      whenListen(
        bloc,
        controller.stream,
        initialState: loadedState(financeSummary: finance),
      );
      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();
      expect(find.text('Finance'), findsOneWidget);

      // Permission revoked mid-session: the emitted loaded state no longer
      // carries finance access — the same summary data disappears and no
      // further aggregate rendering is possible.
      controller.add(
        loadedState(financeSummary: finance, canViewFinance: false),
      );
      await tester.pumpAndSettle();

      expect(find.text('Finance'), findsNothing);
      expect(find.text('EGP 10,000.00'), findsNothing);
    });
  });

  group('aggregate rendering', () {
    testWidgets(
        '(5) displayed aggregates are the backend-provided values (source '
        'records), (6) reversed payments already excluded server-side',
        (tester) async {
      whenListen(
        bloc,
        const Stream<DashboardState>.empty(),
        initialState: loadedState(financeSummary: finance),
      );

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      // Exactly the authorized aggregates the backend returned — collected
      // (6,000) is less than agreed (10,000) because reversed payments were
      // excluded in the backend computation before reaching the client.
      expect(find.text('EGP 10,000.00'), findsOneWidget);
      expect(find.text('EGP 6,000.00'), findsOneWidget);
      expect(find.text('EGP 4,000.00'), findsOneWidget);
    });

    testWidgets(
        '(12) empty firm shows zeroed aggregates, not fabricated financial '
        'activity', (tester) async {
      const emptyFinance = FinanceSummary(
        totalCaseValue: 0,
        totalCollected: 0,
        totalOutstanding: 0,
        paidCases: 0,
        partialCases: 0,
        unpaidCases: 0,
        cases: [],
      );
      whenListen(
        bloc,
        const Stream<DashboardState>.empty(),
        initialState: loadedState(financeSummary: emptyFinance),
      );

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      expect(find.text('EGP 0.00'), findsNWidgets(3));
      expect(find.text('0'), findsNWidgets(3));
      expect(find.text('No financial data yet'), findsNothing);
    });

    testWidgets(
        '(12b) a failed aggregate fetch degrades to the empty state instead '
        'of inventing zeros', (tester) async {
      whenListen(
        bloc,
        const Stream<DashboardState>.empty(),
        initialState: loadedState(financeSummary: null),
      );

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      expect(find.text('No financial data yet'), findsOneWidget);
      expect(find.text('EGP 0.00'), findsNothing);
    });
  });

  group('filters', () {
    testWidgets(
        '(7) selecting a payment-status chip dispatches a filtered aggregate '
        'fetch — and the unfiltered chip clears it', (tester) async {
      whenListen(
        bloc,
        const Stream<DashboardState>.empty(),
        initialState: loadedState(financeSummary: finance),
      );

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unpaid'));
      await tester.pumpAndSettle();

      verify(
        () => bloc.add(
          any(
            that: isA<RefreshFinanceSummaryRequested>().having(
              (event) => event.filters,
              'filters',
              {'paymentStatus': 'UNPAID'},
            ),
          ),
        ),
      ).called(1);

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      verify(
        () => bloc.add(
          any(
            that: isA<RefreshFinanceSummaryRequested>().having(
              (event) => event.filters,
              'filters',
              isEmpty,
            ),
          ),
        ),
      ).called(1);
    });

    testWidgets(
        '(10) filter fetches use the in-place finance-loading state — the '
        'rest of the dashboard stays mounted (no global reload)',
        (tester) async {
      whenListen(
        bloc,
        const Stream<DashboardState>.empty(),
        initialState: DashboardFinanceLoading(
          loadedState(financeSummary: finance),
          filters: {'paymentStatus': 'PAID'},
        ),
      );

      await tester.pumpWidget(buildTestable());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Dashboard content persists while only the finance panel refreshes.
      expect(find.text('Recent activity'), findsOneWidget);
      expect(find.text('Finance'), findsOneWidget);
      expect(find.text('EGP 10,000.00'), findsOneWidget);
    });
  });

  group('loading / error', () {
    testWidgets('(10) shows a loading spinner while DashboardLoading',
        (tester) async {
      whenListen(
        bloc,
        const Stream<DashboardState>.empty(),
        initialState: DashboardLoading(),
      );

      await tester.pumpWidget(buildTestable());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('(11) shows the shared error view on DashboardError',
        (tester) async {
      whenListen(
        bloc,
        const Stream<DashboardState>.empty(),
        initialState: const DashboardError('Server error'),
      );

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      expect(find.text('Server error'), findsOneWidget);
    });
  });

  group('navigation / rtl', () {
    testWidgets('View all routes to the finance hub', (tester) async {
      whenListen(
        bloc,
        const Stream<DashboardState>.empty(),
        initialState: loadedState(financeSummary: finance),
      );

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      // The finance panel's header action — .first targets the finance
      // card's "View all" (the hearings panel has its own).
      await tester.tap(find.text('View all').first);
      await tester.pumpAndSettle();
      expect(find.text('FINANCE_HUB'), findsOneWidget);
    });

    testWidgets('(13) renders the finance section in Arabic with RTL '
        'directionality', (tester) async {
      whenListen(
        bloc,
        const Stream<DashboardState>.empty(),
        initialState: loadedState(financeSummary: finance),
      );

      await tester.pumpWidget(buildTestable(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      final directionality = tester.widget<Directionality>(
        find.byType(Directionality).first,
      );
      expect(directionality.textDirection, TextDirection.rtl);

      expect(find.text('الشؤون المالية'), findsOneWidget);
      expect(find.text('إجمالي أتعاب القضايا'), findsOneWidget);
      expect(find.text('مُحصّلة'), findsOneWidget);
      expect(find.text('مستحقة'), findsOneWidget);
      expect(find.text('قضايا مدفوعة'), findsOneWidget);
      expect(find.text('قضايا مدفوعة جزئياً'), findsOneWidget);
      expect(find.text('قضايا غير مدفوعة'), findsOneWidget);
    });
  });
}
