import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/platform_admin/presentation/pages/provision_firm_page.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

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
  late MockDio dio;
  late Map<Locale, AppLocalizations> localizationsCache;

  Response<T> ok<T>(String path, T data) => Response<T>(
    requestOptions: RequestOptions(path: path),
    data: data,
    statusCode: 200,
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final en = AppLocalizations(const Locale('en'));
    await en.load();
    final ar = AppLocalizations(const Locale('ar'));
    await ar.load();
    localizationsCache = {const Locale('en'): en, const Locale('ar'): ar};
    registerFallbackValue(RequestOptions(path: '/'));
  });

  setUp(() async {
    await getIt.reset();
    dio = MockDio();
    getIt.registerLazySingleton<Dio>(() => dio);

    // The reference data the page loads on open. Platform-management codes are
    // included on purpose: they must never be granted to a firm admin.
    when(
      () => dio.get('/subscriptions/plans'),
    ).thenAnswer((_) async => ok('/subscriptions/plans', <dynamic>[
          {'id': 'plan-1', 'name': 'Premium'},
        ]));
    when(() => dio.get('/permissions')).thenAnswer(
      (_) async => ok('/permissions', {
        'codes': [
          'case.view',
          'employee.read',
          'platform.firm.create',
          'system.tenants.read',
        ],
      }),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  Future<void> pumpProvisionPage(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/firms',
      routes: [
        GoRoute(
          path: '/firms',
          builder: (_, _) => const Scaffold(body: Text('FIRM REGISTRY')),
        ),
        GoRoute(
          path: '/provision',
          builder: (_, _) => const ProvisionFirmPage(),
        ),
      ],
    );

    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: [
          _PreloadedAppLocalizationsDelegate(localizationsCache),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ar')],
        routerConfig: router,
      ),
    );
    router.push('/provision');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Acme Law');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'contact@acme.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'Jane Doe');
    await tester.enterText(find.byType(TextFormField).at(3), 'admin@acme.com');
  }

  testWidgets('provisioning sends only the fields ProvisionTenantDto declares '
      'and applies the permission set through its own endpoint', (
    tester,
  ) async {
    when(
      () => dio.post('/tenants/provision', data: any(named: 'data')),
    ).thenAnswer((_) async => ok('/tenants/provision', {'id': 'firm-9'}));
    when(
      () => dio.patch(
        '/tenants/firm-9/firm-admin/permissions',
        data: any(named: 'data'),
      ),
    ).thenAnswer(
      (_) async => ok('/tenants/firm-9/firm-admin/permissions', null),
    );

    await pumpProvisionPage(tester);
    await tester.tap(find.text('Create Firm & Admin'));
    await tester.pumpAndSettle();

    // The exact body: an extra key (an unsupported field) fails the whole
    // request server-side, which is precisely what `adminPassword` and
    // `permissionKeys` used to cause.
    verify(
      () => dio.post(
        '/tenants/provision',
        data: {
          'firmName': 'Acme Law',
          'firmContactEmail': 'contact@acme.com',
          'adminFullName': 'Jane Doe',
          'adminEmail': 'admin@acme.com',
          'adminJobClassification': 'OTHER',
          'planId': 'plan-1',
          'billingCycle': 'MONTHLY',
        },
      ),
    ).called(1);

    // The Firm Admin's set is replaced after creation, with platform codes
    // excluded and the codes sorted for a stable request.
    verify(
      () => dio.patch(
        '/tenants/firm-9/firm-admin/permissions',
        data: {
          'permissionKeys': ['case.view', 'employee.read'],
        },
      ),
    ).called(1);

    // Success returns to the firm registry.
    expect(find.text('FIRM REGISTRY'), findsOneWidget);
  });

  testWidgets('a rejected provision shows the backend message and does not '
      'attempt the permission step', (tester) async {
    when(
      () => dio.post('/tenants/provision', data: any(named: 'data')),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/tenants/provision'),
        response: Response(
          requestOptions: RequestOptions(path: '/tenants/provision'),
          statusCode: 400,
          data: {'message': 'property adminPassword should not exist'},
        ),
      ),
    );

    await pumpProvisionPage(tester);
    await tester.tap(find.text('Create Firm & Admin'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    verifyNever(
      () => dio.patch(
        any(that: startsWith('/tenants/')),
        data: any(named: 'data'),
      ),
    );
    expect(find.textContaining('unsupported field'), findsOneWidget);
  });
}
