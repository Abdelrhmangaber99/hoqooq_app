import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/auth/permission_codes.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/authentication/presentation/bloc/session_cubit.dart';
import 'package:hqooq/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:hqooq/features/dashboard/domain/repository/i_dashboard_repository.dart';
import 'package:hqooq/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:hqooq/features/finance/domain/entities/finance_summary.dart';
import 'package:hqooq/features/finance/domain/repository/i_finance_repository.dart';
import 'package:hqooq/features/hearings/domain/entities/hearing.dart';
import 'package:hqooq/features/hearings/domain/entities/hearing_status.dart';
import 'package:hqooq/features/hearings/domain/repository/i_hearing_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockDashboardRepository extends Mock implements IDashboardRepository {}

class MockHearingRepository extends Mock implements IHearingRepository {}

class MockFinanceRepository extends Mock implements IFinanceRepository {}

void main() {
  late MockDashboardRepository dashboardRepository;
  late MockHearingRepository hearingRepository;
  late MockFinanceRepository financeRepository;
  late SessionCubit sessionCubit;

  const metrics = DashboardMetrics(
    totalCases: 20,
    totalActiveCases: 14,
    pendingTasks: 2,
    upcomingHearings: 3,
  );
  const finance = FinanceSummary(
    totalCaseValue: 1000,
    totalCollected: 600,
    totalOutstanding: 400,
    paidCases: 1,
    partialCases: 1,
    unpaidCases: 0,
    cases: [],
  );

  const filteredFinance = FinanceSummary(
    totalCaseValue: 300,
    totalCollected: 0,
    totalOutstanding: 300,
    paidCases: 0,
    partialCases: 0,
    unpaidCases: 1,
    cases: [],
  );

  User buildUser({
    List<String> permissions = const [],
    String? classification,
  }) =>
      User(
        id: 'u1',
        email: 'lawyer@firm.com',
        fullName: 'Jane Doe',
        isSuperAdmin: false,
        status: 'ACTIVE',
        mfaEnabled: false,
        permissions: permissions,
        jobClassification: classification,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        tenant: const TenantRef(id: 't1', name: 'Reynolds & Associates'),
      );

  Hearing buildHearing({
    required String id,
    required DateTime scheduledAt,
    HearingStatus status = HearingStatus.scheduled,
  }) => Hearing(
    id: id,
    caseId: 'case-$id',
    courtId: 'court-1',
    hearingTypeId: 'type-1',
    scheduledAt: scheduledAt,
    status: status,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    dashboardRepository = MockDashboardRepository();
    hearingRepository = MockHearingRepository();
    financeRepository = MockFinanceRepository();
    sessionCubit = SessionCubit();
  });

  DashboardBloc buildBloc() => DashboardBloc(
    dashboardRepository,
    hearingRepository,
    financeRepository,
    sessionCubit,
  );

  blocTest<DashboardBloc, DashboardState>(
    'loads KPIs, upcoming scheduled hearings, and finance when permitted',
    build: () {
      sessionCubit.authenticated(
        buildUser(
          permissions: const [
            PermissionCodes.hearingView,
            PermissionCodes.financeFirmRead,
          ],
        ),
        'token',
        isFirmAdmin: false,
      );
      final now = DateTime.now();
      final later = buildHearing(
        id: 'later',
        scheduledAt: now.add(const Duration(days: 3)),
      );
      final sooner = buildHearing(
        id: 'sooner',
        scheduledAt: now.add(const Duration(days: 1)),
      );
      final completed = buildHearing(
        id: 'completed',
        scheduledAt: now.add(const Duration(days: 2)),
        status: HearingStatus.completed,
      );
      final past = buildHearing(
        id: 'past',
        scheduledAt: now.subtract(const Duration(days: 1)),
      );
      when(
        () => dashboardRepository.getMetrics(),
      ).thenAnswer((_) async => const Right(metrics));
      when(
        () => hearingRepository.getHearings(),
      ).thenAnswer((_) async => Right([later, completed, past, sooner]));
      when(
        () => financeRepository.getSummary(),
      ).thenAnswer((_) async => const Right(finance));
      return buildBloc();
    },
    act: (bloc) => bloc.add(FetchDashboardRequested()),
    expect: () => [
      isA<DashboardLoading>(),
      isA<DashboardLoaded>()
          .having(
            (state) => state.upcomingHearings.map((h) => h.id).toList(),
            'ordered upcoming hearings',
            ['sooner', 'later'],
          )
          .having((state) => state.financeSummary, 'finance summary', finance)
          .having((state) => state.canViewFinance, 'finance access', true),
    ],
  );

  blocTest<DashboardBloc, DashboardState>(
    'emits Error when the required KPI request fails',
    build: () {
      sessionCubit.authenticated(
        buildUser(
          permissions: const [
            PermissionCodes.hearingView,
            PermissionCodes.financeFirmRead,
          ],
        ),
        'token',
        isFirmAdmin: false,
      );
      when(
        () => dashboardRepository.getMetrics(),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return buildBloc();
    },
    act: (bloc) => bloc.add(FetchDashboardRequested()),
    expect: () => [isA<DashboardLoading>(), isA<DashboardError>()],
    verify: (_) {
      verifyNever(() => hearingRepository.getHearings());
      verifyNever(() => financeRepository.getSummary());
    },
  );

  blocTest<DashboardBloc, DashboardState>(
    'degrades secondary request failures to empty Dashboard panels',
    build: () {
      sessionCubit.authenticated(
        buildUser(
          permissions: const [
            PermissionCodes.hearingView,
            PermissionCodes.financeFirmRead,
          ],
        ),
        'token',
        isFirmAdmin: false,
      );
      when(
        () => dashboardRepository.getMetrics(),
      ).thenAnswer((_) async => const Right(metrics));
      when(
        () => hearingRepository.getHearings(),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      when(
        () => financeRepository.getSummary(),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return buildBloc();
    },
    act: (bloc) => bloc.add(FetchDashboardRequested()),
    expect: () => [
      isA<DashboardLoading>(),
      isA<DashboardLoaded>()
          .having((state) => state.upcomingHearings, 'hearings', isEmpty)
          .having((state) => state.financeSummary, 'finance', isNull),
    ],
  );

  blocTest<DashboardBloc, DashboardState>(
    '(8) emits Loaded with the authorized aggregates; totals come from the '
    'backend, not client-side derivation',
    setUp: () {
      sessionCubit.authenticated(
        buildUser(
          permissions: const [PermissionCodes.financeFirmRead],
        ),
        'token',
        isFirmAdmin: false,
      );
      when(
        () => dashboardRepository.getMetrics(),
      ).thenAnswer((_) async => const Right(metrics));
      when(
        () => financeRepository.getSummary(),
      ).thenAnswer((_) async => const Right(finance));
    },
    build: buildBloc,
    act: (bloc) => bloc.add(FetchDashboardRequested()),
    expect: () => [
      isA<DashboardLoading>(),
      isA<DashboardLoaded>()
          .having(
            (state) => state.financeSummary?.totalCollected,
            'collected',
            600,
          )
          .having(
            (state) =>
                state.financeSummary!.paidCases +
                state.financeSummary!.partialCases +
                state.financeSummary!.unpaidCases,
            'case counts sum',
            2,
          ),
    ],
    verify: (_) {
      // Aggregates requested exactly once, with no client-side follow-ups.
      verify(() => financeRepository.getSummary()).called(1);
    },
  );

  blocTest<DashboardBloc, DashboardState>(
    '(2)(3)(4) never requests firm aggregates without finance.firm.read — '
    'including ACCOUNTANT-classified and case-only finance users',
    setUp: () {
      sessionCubit.authenticated(
        buildUser(
          permissions: const [
            PermissionCodes.financeCaseView,
            PermissionCodes.financePaymentRecord,
          ],
          classification: 'ACCOUNTANT',
        ),
        'token',
        isFirmAdmin: false,
      );
      when(
        () => dashboardRepository.getMetrics(),
      ).thenAnswer((_) async => const Right(metrics));
    },
    build: buildBloc,
    act: (bloc) => bloc.add(FetchDashboardRequested()),
    expect: () => [
      isA<DashboardLoading>(),
      isA<DashboardLoaded>()
          .having((state) => state.canViewFinance, 'finance access', false),
    ],
    verify: (_) {
      verifyNever(() => financeRepository.getSummary());
    },
  );

  blocTest<DashboardBloc, DashboardState>(
    '(7) filter change re-requests the aggregate endpoint with the filters '
    'and replaces the summary in place',
    setUp: () {
      sessionCubit.authenticated(
        buildUser(
          permissions: const [PermissionCodes.financeFirmRead],
        ),
        'token',
        isFirmAdmin: false,
      );
      when(
        () => dashboardRepository.getMetrics(),
      ).thenAnswer((_) async => const Right(metrics));
      when(
        () => financeRepository.getSummary(),
      ).thenAnswer((_) async => const Right(finance));
      when(
        () => financeRepository.getSummary(
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => const Right(filteredFinance));
    },
    build: buildBloc,
    act: (bloc) async {
      bloc.add(FetchDashboardRequested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(
        const RefreshFinanceSummaryRequested(
          filters: {'paymentStatus': 'UNPAID'},
        ),
      );
    },
    expect: () => [
      isA<DashboardLoading>(),
      isA<DashboardLoaded>(),
      isA<DashboardFinanceLoading>()
          .having(
            (state) => state.filters,
            'filters in flight',
            {'paymentStatus': 'UNPAID'},
          ),
      isA<DashboardLoaded>()
          .having(
            (state) => state.financeSummary,
            'filtered summary',
            filteredFinance,
          )
          .having(
            (state) => state.financeFilters,
            'active filters',
            {'paymentStatus': 'UNPAID'},
          ),
    ],
    verify: (_) {
      final calls = verify(
        () => financeRepository.getSummary(
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      )..called(2);
      expect(
        calls.captured.last,
        {'paymentStatus': 'UNPAID'},
      );
    },
  );

  blocTest<DashboardBloc, DashboardState>(
    'clearing a filter re-requests the unfiltered aggregates',
    setUp: () {
      sessionCubit.authenticated(
        buildUser(
          permissions: const [PermissionCodes.financeFirmRead],
        ),
        'token',
        isFirmAdmin: false,
      );
      when(
        () => dashboardRepository.getMetrics(),
      ).thenAnswer((_) async => const Right(metrics));
      when(
        () => financeRepository.getSummary(
          queryParameters: any(named: 'queryParameters', that: isNull),
        ),
      ).thenAnswer((_) async => const Right(finance));
    },
    build: buildBloc,
    seed: () => DashboardLoaded(
      metrics,
      financeSummary: finance,
      financeFilters: const {'paymentStatus': 'UNPAID'},
      canViewFinance: true,
    ),
    act: (bloc) =>
        bloc.add(const RefreshFinanceSummaryRequested(filters: {})),
    expect: () => [
      isA<DashboardFinanceLoading>(),
      isA<DashboardLoaded>()
          .having(
            (state) => state.financeFilters,
            'filters cleared',
            isEmpty,
          )
          .having(
            (state) => state.financeSummary,
            'unfiltered summary',
            finance,
          ),
    ],
  );

  blocTest<DashboardBloc, DashboardState>(
    '(14) ignores finance refresh requests once finance.firm.read is '
    'revoked mid-session — no stale data, no further requests',
    setUp: () {
      when(
        () => dashboardRepository.getMetrics(),
      ).thenAnswer((_) async => const Right(metrics));
    },
    build: () {
      // Revoked before the refresh arrives: unauthenticated-adjacent user
      // with no firm-finance grant.
      sessionCubit.authenticated(
        buildUser(permissions: const []),
        'token',
        isFirmAdmin: false,
      );
      return buildBloc();
    },
    seed: () => DashboardLoaded(
      metrics,
      financeSummary: finance,
      canViewFinance: false,
    ),
    act: (bloc) => bloc.add(
      const RefreshFinanceSummaryRequested(
        filters: {'paymentStatus': 'PAID'},
      ),
    ),
    expect: () => <DashboardState>[],
    verify: (_) {
      verifyNever(
        () => financeRepository.getSummary(
          queryParameters: any(named: 'queryParameters'),
        ),
      );
    },
  );

  blocTest<DashboardBloc, DashboardState>(
    'a failed filtered fetch keeps the last-loaded aggregates visible',
    setUp: () {
      sessionCubit.authenticated(
        buildUser(
          permissions: const [PermissionCodes.financeFirmRead],
        ),
        'token',
        isFirmAdmin: false,
      );
      when(
        () => dashboardRepository.getMetrics(),
      ).thenAnswer((_) async => const Right(metrics));
      when(
        () => financeRepository.getSummary(
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => const Left(NetworkFailure()));
    },
    build: buildBloc,
    seed: () => DashboardLoaded(
      metrics,
      financeSummary: finance,
      canViewFinance: true,
    ),
    act: (bloc) => bloc.add(
      const RefreshFinanceSummaryRequested(
        filters: {'paymentStatus': 'PAID'},
      ),
    ),
    expect: () => [
      isA<DashboardFinanceLoading>(),
      isA<DashboardFinanceError>()
          .having(
            (state) => state.financeSummary,
            'previous summary retained',
            finance,
          )
          .having((state) => state.error, 'error', 'No internet connection'),
    ],
  );
}
