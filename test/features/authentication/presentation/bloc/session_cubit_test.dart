import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
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
    tenant: const TenantRef(id: 't1', name: 'Reynolds & Associates'),
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
}
