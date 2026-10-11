import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/platform_admin/presentation/pages/firm_details_page.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class _Delegate extends LocalizationsDelegate<AppLocalizations> {
  const _Delegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) => SynchronousFuture(
    AppLocalizations.withMap(locale, const {
      'firm_details': 'Firm details',
      'firm_employees': 'Firm employees',
      'no_employees_found': 'No employees found',
      'unnamed_employee': 'Unnamed employee',
      'could_not_load_firm': 'Could not load firm',
      'try_again': 'Try again',
    }),
  );

  @override
  bool shouldReload(_Delegate old) => false;
}

void main() {
  late MockDio dio;

  setUp(() async {
    await getIt.reset();
    dio = MockDio();
    getIt.registerSingleton<Dio>(dio);
  });

  tearDown(() => getIt.reset());

  testWidgets('renders the created Firm Admin from the tenant overview', (
    tester,
  ) async {
    when(() => dio.get('/tenants/firm-1')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/tenants/firm-1'),
        statusCode: 200,
        data: {
          'firm': {
            'id': 'firm-1',
            'name': 'North Law',
            'status': 'ACTIVE',
            'ownerUserId': 'admin-1',
            'contactEmail': 'contact@north.test',
          },
          'employees': [
            {
              'id': 'admin-1',
              'email': 'admin@north.test',
              'fullName': 'North Admin',
              'status': 'INVITED',
              'jobClassification': 'LAWYER',
            },
          ],
          'currentSubscription': null,
        },
      ),
    );
    when(() => dio.get('/subscriptions/plans')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/subscriptions/plans'),
        statusCode: 200,
        data: const <dynamic>[],
      ),
    );
    when(() => dio.get('/users')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/users'),
        statusCode: 200,
        data: const <dynamic>[],
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: [_Delegate()],
        home: FirmDetailsPage(firmId: 'firm-1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('North Law'), findsOneWidget);
    expect(find.textContaining('North Admin'), findsWidgets);
    expect(find.text('Firm Admin'), findsOneWidget);
    expect(find.textContaining('admin@north.test'), findsOneWidget);
    verify(() => dio.get('/tenants/firm-1')).called(1);
  });

  testWidgets('treats the first overview account as admin on older payloads', (
    tester,
  ) async {
    when(() => dio.get('/tenants/firm-1')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/tenants/firm-1'),
        statusCode: 200,
        data: {
          'firm': {
            'id': 'firm-1',
            'name': 'North Law',
            'status': 'ACTIVE',
            'ownerUserId': null,
          },
          'employees': [
            {
              'id': 'admin-1',
              'email': 'admin@north.test',
              'fullName': 'North Admin',
              'status': 'ACTIVE',
            },
          ],
          'currentSubscription': null,
        },
      ),
    );
    when(() => dio.get('/subscriptions/plans')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/subscriptions/plans'),
        statusCode: 200,
        data: const <dynamic>[],
      ),
    );
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: [_Delegate()],
        home: FirmDetailsPage(firmId: 'firm-1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('North Admin'), findsWidgets);
    expect(find.text('Firm Admin'), findsOneWidget);
    expect(find.textContaining('admin@north.test'), findsOneWidget);
  });

  testWidgets('opens from enriched list data when overview fails', (
    tester,
  ) async {
    when(() => dio.get('/tenants/firm-1')).thenThrow(
      DioException(requestOptions: RequestOptions(path: '/tenants/firm-1')),
    );
    when(() => dio.get('/subscriptions/plans')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/subscriptions/plans'),
        statusCode: 200,
        data: const <dynamic>[],
      ),
    );
    when(() => dio.get('/users')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/users'),
        statusCode: 200,
        data: const <dynamic>[],
      ),
    );
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: [_Delegate()],
        home: FirmDetailsPage(
          firmId: 'firm-1',
          initialFirm: {
            'id': 'firm-1',
            'name': 'North Law',
            'status': 'ACTIVE',
            'ownerUserId': 'admin-1',
            '_employees': [
              {
                'id': 'admin-1',
                'email': 'admin@north.test',
                'fullName': 'North Admin',
                'status': 'INVITED',
              },
            ],
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('North Law'), findsOneWidget);
    expect(find.textContaining('North Admin'), findsWidgets);
    expect(find.text('Firm Admin'), findsOneWidget);
    expect(find.textContaining('admin@north.test'), findsOneWidget);
  });

  testWidgets('renders the Firm Admin from the deployed registry shape', (
    tester,
  ) async {
    // Live deployed shape: {firm, firmAdmin, currentSubscription} with no
    // employee list (a Super Admin has no GET /users and is refused
    // GET /employees), so the embedded firmAdmin is the only source.
    when(() => dio.get('/tenants/firm-1')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/tenants/firm-1'),
        statusCode: 200,
        data: {
          'firm': {
            'id': 'firm-1',
            'name': 'North Law',
            'status': 'ACTIVE',
            'contactEmail': 'contact@north.test',
          },
          'firmAdmin': {
            'id': 'admin-1',
            'fullName': 'North Admin',
            'email': 'admin@north.test',
            'status': 'ACTIVE',
          },
          'currentSubscription': {'status': 'ACTIVE'},
        },
      ),
    );
    when(() => dio.get('/subscriptions/plans')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/subscriptions/plans'),
        statusCode: 200,
        data: const <dynamic>[],
      ),
    );
    when(() => dio.get('/users')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/users'),
        statusCode: 200,
        data: const <dynamic>[],
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: [_Delegate()],
        home: FirmDetailsPage(firmId: 'firm-1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('North Law'), findsOneWidget);
    expect(find.textContaining('North Admin'), findsWidgets);
    expect(find.text('Firm Admin'), findsOneWidget);
    expect(find.textContaining('admin@north.test'), findsOneWidget);
  });
}
