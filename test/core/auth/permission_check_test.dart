import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/auth/permission_check.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/authentication/domain/entities/permission.dart';
import 'package:hqooq/features/authentication/domain/entities/role.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/authentication/presentation/bloc/session_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
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
    roles: const [
      Role(
        id: 'r1',
        code: 'LAWYER',
        scope: 'TENANT',
        permissions: [Permission(id: 'p1', code: 'cases.create')],
      ),
    ],
    tenant: const TenantRef(id: 't1', name: 'Reynolds & Associates'),
  );

  setUp(() async {
    await getIt.reset();
    sessionCubit = MockSessionCubit();
    getIt.registerSingleton<SessionCubit>(sessionCubit);
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('true when the authenticated user holds the exact permission code', () {
    when(
      () => sessionCubit.state,
    ).thenReturn(SessionAuthenticated(user, isFirmAdmin: false));

    expect(currentUserHasPerm('cases.create'), isTrue);
  });

  test('false when the authenticated user lacks the permission code', () {
    when(
      () => sessionCubit.state,
    ).thenReturn(SessionAuthenticated(user, isFirmAdmin: false));

    expect(currentUserHasPerm('cases.delete'), isFalse);
  });

  test('false (secure default) when there is no authenticated session', () {
    when(() => sessionCubit.state).thenReturn(const SessionUnknown());

    expect(currentUserHasPerm('cases.create'), isFalse);
  });
}
