import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/authentication/domain/entities/role.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/authentication/presentation/bloc/session_cubit.dart';

void main() {
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

  final firmAdminUser = user.copyWith(
    roles: const [
      Role(id: 'r1', code: 'FIRM_ADMIN', scope: 'TENANT', permissions: []),
    ],
  );

  blocTest<SessionCubit, SessionState>(
    'authenticated() emits SessionAuthenticated and sets the access token',
    build: SessionCubit.new,
    act: (cubit) => cubit.authenticated(user, 'token-1', isFirmAdmin: false),
    expect: () => [SessionAuthenticated(user, isFirmAdmin: false)],
    verify: (cubit) => expect(cubit.accessToken, 'token-1'),
  );

  blocTest<SessionCubit, SessionState>(
    'unauthenticated() emits SessionUnauthenticated and clears the token',
    build: SessionCubit.new,
    act: (cubit) {
      cubit.authenticated(user, 'token-1', isFirmAdmin: false);
      cubit.unauthenticated();
    },
    expect: () => [
      SessionAuthenticated(user, isFirmAdmin: false),
      const SessionUnauthenticated(),
    ],
    verify: (cubit) => expect(cubit.accessToken, isNull),
  );

  blocTest<SessionCubit, SessionState>(
    'subscriptionInactive() emits SessionSubscriptionInactive for the '
    'last-known user, without clearing the access token (not a logout)',
    build: SessionCubit.new,
    act: (cubit) {
      cubit.authenticated(user, 'token-1', isFirmAdmin: false);
      cubit.subscriptionInactive('Your subscription has expired.');
    },
    skip: 1,
    expect: () => [
      SessionSubscriptionInactive(
        user,
        message: 'Your subscription has expired.',
      ),
    ],
    verify: (cubit) => expect(cubit.accessToken, 'token-1'),
  );

  blocTest<SessionCubit, SessionState>(
    'subscriptionInactive() is a no-op when there is no known user',
    build: SessionCubit.new,
    act: (cubit) => cubit.subscriptionInactive('unexpected'),
    expect: () => <SessionState>[],
  );

  blocTest<SessionCubit, SessionState>(
    'subscriptionReactivated() returns to SessionAuthenticated for the '
    'same user, recomputing isFirmAdmin from their roles',
    build: SessionCubit.new,
    act: (cubit) {
      cubit.authenticated(firmAdminUser, 'token-1', isFirmAdmin: true);
      cubit.subscriptionInactive('expired');
      cubit.subscriptionReactivated();
    },
    skip: 2,
    expect: () => [SessionAuthenticated(firmAdminUser, isFirmAdmin: true)],
  );
}
