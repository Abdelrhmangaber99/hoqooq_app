import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/router/app_router.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/authentication/presentation/bloc/session_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionCubit extends MockCubit<SessionState> implements SessionCubit {}

/// Guards the shape of the real route table, which nothing else in the suite
/// touches — a route that shadows a sibling would break the whole app and no
/// page-level test would catch it.
void main() {
  late MockSessionCubit sessionCubit;

  setUp(() async {
    await getIt.reset();
    sessionCubit = MockSessionCubit();
    getIt.registerSingleton<SessionCubit>(sessionCubit);
    when(() => sessionCubit.state).thenReturn(
      SessionAuthenticated(
        User(
          id: 'u1',
          email: 'admin@firm.com',
          fullName: 'Admin',
          status: 'ACTIVE',
          accountType: 'FIRM_ADMIN',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
          tenant: const TenantRef(id: 't1', name: 'Firm'),
        ),
        isFirmAdmin: true,
      ),
    );
    whenListen(
      sessionCubit,
      const Stream<SessionState>.empty(),
      initialState: const SessionUnauthenticated(),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('the router table builds without a path conflict', () {
    expect(AppRouter.router, isNotNull);
  });

  test('/tasks/new resolves to the create form, not the :taskId detail route', () {
    // The detail route was added as a sibling of the existing `new` and
    // `:taskId/edit` routes. If `:taskId` had won, `pathParameters` would carry
    // `taskId: 'new'` and the create form would be unreachable.
    final match = AppRouter.router.configuration.findMatch(
      Uri.parse('/tasks/new'),
    );
    expect(match.pathParameters, isEmpty);
    expect(match.fullPath, '/tasks/new');
  });

  test('/tasks/:taskId resolves to the detail route', () {
    final match = AppRouter.router.configuration.findMatch(
      Uri.parse('/tasks/abc-123'),
    );
    expect(match.pathParameters['taskId'], 'abc-123');
  });

  test('the pre-existing tasks routes still resolve', () {
    final newMatch = AppRouter.router.configuration.findMatch(
      Uri.parse('/tasks'),
    );
    expect(newMatch.fullPath, '/tasks');

    final editMatch = AppRouter.router.configuration.findMatch(
      Uri.parse('/tasks/abc-123/edit'),
    );
    expect(editMatch.pathParameters['taskId'], 'abc-123');
  });
}
