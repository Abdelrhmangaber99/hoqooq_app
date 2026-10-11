import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/platform_admin/presentation/pages/firm_admin_details_page.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;

  setUp(() async {
    await getIt.reset();
    dio = MockDio();
    getIt.registerSingleton<Dio>(dio);
  });

  tearDown(() => getIt.reset());

  DioException notFound(String path) => DioException(
    requestOptions: RequestOptions(path: path),
    response: Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 404,
    ),
  );

  Future<void> pumpPage(
    WidgetTester tester, {
    required Map<String, dynamic> admin,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FirmAdminDetailsPage(
          firm: const {'id': 'firm-1', 'name': 'North Law'},
          admin: admin,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapDeactivate(WidgetTester tester) async {
    final button = find.text('Deactivate account');
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('renders the registry-provided Firm Admin', (tester) async {
    await pumpPage(
      tester,
      admin: const {
        'id': 'admin-1',
        'fullName': 'North Admin',
        'email': 'admin@north.test',
        'status': 'ACTIVE',
      },
    );

    expect(find.text('North Admin'), findsOneWidget);
    expect(find.text('admin@north.test'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);
    expect(find.text('admin-1'), findsOneWidget);
  });

  testWidgets('deactivates through the platform status route when present', (
    tester,
  ) async {
    when(() => dio.patch<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/users/admin-1/status'),
        statusCode: 200,
      ),
    );
    await pumpPage(tester, admin: const {'id': 'admin-1', 'status': 'ACTIVE'});

    await tapDeactivate(tester);

    verify(
      () => dio.patch<dynamic>('/users/admin-1/status', data: {
        'status': 'INACTIVE',
      }),
    ).called(1);
    expect(find.text('Account status changed to INACTIVE.'), findsOneWidget);
  });

  testWidgets('explains plainly when the backend has no status route', (
    tester,
  ) async {
    when(
      () => dio.patch<dynamic>('/users/admin-1/status', data: any(named: 'data')),
    ).thenThrow(notFound('/users/admin-1/status'));
    await pumpPage(tester, admin: const {'id': 'admin-1', 'status': 'ACTIVE'});

    await tapDeactivate(tester);

    expect(find.textContaining('no endpoint to change a Firm Admin'), findsOneWidget);
  });

  testWidgets('targets the account user id, not the employee id', (
    tester,
  ) async {
    when(() => dio.patch<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/users/admin-2/status'),
        statusCode: 200,
      ),
    );
    await pumpPage(
      tester,
      admin: const {
        'id': 'emp-9',
        'userId': 'admin-2',
        'user': {'id': 'admin-2', 'fullName': 'Nested Admin'},
      },
    );

    await tapDeactivate(tester);

    verify(
      () => dio.patch<dynamic>('/users/admin-2/status', data: {
        'status': 'INACTIVE',
      }),
    ).called(1);
  });
}
