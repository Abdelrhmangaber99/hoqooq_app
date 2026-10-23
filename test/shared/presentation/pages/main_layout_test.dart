import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hqooq/core/auth/permission_codes.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:hqooq/features/authentication/presentation/bloc/session_cubit.dart';
import 'package:hqooq/features/subscriptions/presentation/bloc/subscription_cubit.dart';
import 'package:hqooq/features/subscriptions/presentation/bloc/subscription_state.dart';
import 'package:hqooq/shared/presentation/pages/main_layout.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

class MockSubscriptionCubit extends MockCubit<SubscriptionState>
    implements SubscriptionCubit {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class _PreloadedAppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _PreloadedAppLocalizationsDelegate(this._cache);

  final Map<Locale, AppLocalizations> _cache;

  @override
  bool isSupported(Locale locale) => _cache.containsKey(locale);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(_cache[locale]!);

  @override
  bool shouldReload(_PreloadedAppLocalizationsDelegate old) => false;
}

void main() {
  late MockSessionCubit sessionCubit;
  late MockSubscriptionCubit subscriptionCubit;
  late MockAuthBloc authBloc;
  late Map<Locale, AppLocalizations> localizationsCache;

  User buildUser({
    required String accountType,
    List<String> permissions = const [],
  }) => User(
    id: 'u1',
    email: 'user@test.com',
    fullName: 'Test User',
    status: 'ACTIVE',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    accountType: accountType,
    permissions: permissions,
    tenant: const TenantRef(id: 't1', name: 'Test Firm'),
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final en = AppLocalizations(const Locale('en'));
    await en.load();
    final ar = AppLocalizations(const Locale('ar'));
    await ar.load();
    localizationsCache = {const Locale('en'): en, const Locale('ar'): ar};
  });

  setUp(() async {
    await getIt.reset();
    sessionCubit = MockSessionCubit();
    subscriptionCubit = MockSubscriptionCubit();
    authBloc = MockAuthBloc();

    getIt.registerSingleton<SessionCubit>(sessionCubit);
    getIt.registerSingleton<SubscriptionCubit>(subscriptionCubit);
    getIt.registerSingleton<AuthBloc>(authBloc);

    when(() => subscriptionCubit.state).thenReturn(SubscriptionInitial());
    when(
      () => subscriptionCubit.stream,
    ).thenAnswer((_) => Stream.value(SubscriptionInitial()));
    when(() => authBloc.state).thenReturn(AuthInitial());
  });

  Widget buildTestApp(User user) {
    final isFirmAdmin = user.isFirmAdmin;
    when(
      () => sessionCubit.state,
    ).thenReturn(SessionAuthenticated(user, isFirmAdmin: isFirmAdmin));
    when(() => sessionCubit.stream).thenAnswer(
      (_) => Stream.value(SessionAuthenticated(user, isFirmAdmin: isFirmAdmin)),
    );

    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        ShellRoute(
          builder: (context, state, child) => MultiBlocProvider(
            providers: [
              BlocProvider<SessionCubit>.value(value: sessionCubit),
              BlocProvider<SubscriptionCubit>.value(value: subscriptionCubit),
              BlocProvider<AuthBloc>.value(value: authBloc),
            ],
            child: MainLayout(child: child),
          ),
          routes: [
            GoRoute(
              path: '/home',
              builder: (_, __) => const Text('Home Screen'),
            ),
            GoRoute(
              path: '/cases',
              builder: (_, __) => const Text('Cases Screen'),
            ),
            GoRoute(
              path: '/clients',
              builder: (_, __) => const Text('Clients Screen'),
            ),
            GoRoute(
              path: '/hearings',
              builder: (_, __) => const Text('Hearings Screen'),
            ),
            GoRoute(
              path: '/tasks',
              builder: (_, __) => const Text('Tasks Screen'),
            ),
            GoRoute(
              path: '/calendar',
              builder: (_, __) => const Text('Calendar Screen'),
            ),
            GoRoute(
              path: '/finance',
              builder: (_, __) => const Text('Finance Screen'),
            ),
            GoRoute(
              path: '/reports',
              builder: (_, __) => const Text('Reports Screen'),
            ),
            GoRoute(
              path: '/employees',
              builder: (_, __) => const Text('Employees Screen'),
            ),
            GoRoute(
              path: '/settings',
              builder: (_, __) => const Text('Settings Screen'),
            ),
            GoRoute(
              path: '/alerts',
              builder: (_, __) => const Text('Alerts Screen'),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: [
        _PreloadedAppLocalizationsDelegate(localizationsCache),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
      locale: const Locale('en'),
    );
  }

  testWidgets('Firm Admin sees all navigation tabs in layout', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final admin = buildUser(accountType: 'FIRM_ADMIN');
    await tester.pumpWidget(buildTestApp(admin));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Cases'), findsOneWidget);
    expect(find.text('Clients'), findsOneWidget);
    expect(find.text('Hearings'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Finance'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('Employees'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('NOTIFICATIONS'), findsOneWidget);
  });

  testWidgets(
    'Employee with NO permissions sees Home, Calendar, Notifications',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final employee = buildUser(accountType: 'EMPLOYEE', permissions: []);
      await tester.pumpWidget(buildTestApp(employee));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Cases'), findsNothing);
      expect(find.text('Clients'), findsNothing);
      expect(find.text('Hearings'), findsNothing);
      expect(find.text('Tasks'), findsNothing);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Finance'), findsNothing);
      expect(find.text('Reports'), findsNothing);
      expect(find.text('Employees'), findsNothing);
      // `firm.profile.read` and Firm Admin status are both absent here.
      expect(find.text('Settings'), findsNothing);
      expect(find.text('Subscription'), findsNothing);
      expect(find.text('NOTIFICATIONS'), findsOneWidget);
    },
  );

  testWidgets(
    'Employee with case.view and hearing.view permissions sees Cases, Clients, Hearings',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final employee = buildUser(
        accountType: 'EMPLOYEE',
        permissions: [PermissionCodes.caseView, PermissionCodes.hearingView],
      );
      await tester.pumpWidget(buildTestApp(employee));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Cases'), findsOneWidget);
      expect(find.text('Clients'), findsOneWidget);
      expect(find.text('Hearings'), findsOneWidget);
      expect(find.text('Tasks'), findsNothing);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Finance'), findsNothing);
      expect(find.text('Reports'), findsNothing);
      expect(find.text('Employees'), findsNothing);
      expect(find.text('Settings'), findsNothing);
      expect(find.text('Subscription'), findsNothing);
      expect(find.text('NOTIFICATIONS'), findsOneWidget);
    },
  );

  testWidgets(
    'an Employee granted the deployed employee.view code sees Employees',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // `PermissionCodes.employeeRead` is `employee.view` — the code the
      // deployed backend actually grants. This is the exact scenario the app
      // used to fail: the sidebar checked `employee.read`, the account held
      // `employee.view`, and the module stayed hidden.
      final employee = buildUser(
        accountType: 'EMPLOYEE',
        permissions: [PermissionCodes.employeeRead],
      );
      await tester.pumpWidget(buildTestApp(employee));
      await tester.pumpAndSettle();

      expect(PermissionCodes.employeeRead, 'employee.view');
      expect(find.text('Employees'), findsOneWidget);
    },
  );

  testWidgets(
    'an Employee granted firm.profile.read sees Settings',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final employee = buildUser(
        accountType: 'EMPLOYEE',
        permissions: [PermissionCodes.firmProfileRead],
      );
      await tester.pumpWidget(buildTestApp(employee));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Subscription'), findsNothing);
    },
  );
}
