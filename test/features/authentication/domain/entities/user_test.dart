import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/authentication/domain/entities/permission.dart';
import 'package:hqooq/features/authentication/domain/entities/role.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';

void main() {
  User buildUser({List<Role> roles = const []}) {
    return User(
      id: 'u1',
      email: 'lawyer@firm.com',
      fullName: 'Jane Doe',
      isSuperAdmin: false,
      status: 'ACTIVE',
      mfaEnabled: false,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      roles: roles,
      tenant: const TenantRef(id: 't1', name: 'Reynolds & Associates'),
    );
  }

  test('fullName is the API-provided value', () {
    expect(buildUser().fullName, 'Jane Doe');
  });

  group('hasPerm', () {
    test('is true when any role grants the exact permission code', () {
      final user = buildUser(
        roles: [
          const Role(
            id: 'r1',
            code: 'LAWYER',
            scope: 'TENANT',
            permissions: [Permission(id: 'p1', code: 'cases.read')],
          ),
        ],
      );

      expect(user.hasPerm('cases.read'), isTrue);
    });

    test('is false when no role grants the code', () {
      expect(buildUser().hasPerm('cases.read'), isFalse);
    });

    test('does not match a different code', () {
      final user = buildUser(
        roles: [
          const Role(
            id: 'r1',
            code: 'LAWYER',
            scope: 'TENANT',
            permissions: [Permission(id: 'p1', code: 'cases.read')],
          ),
        ],
      );

      expect(user.hasPerm('cases.delete'), isFalse);
    });
  });

  group('isFirmAdmin', () {
    test('is true when any role has code FIRM_ADMIN', () {
      final user = buildUser(
        roles: const [
          Role(id: 'r1', code: 'FIRM_ADMIN', scope: 'TENANT', permissions: []),
        ],
      );

      expect(user.isFirmAdmin, isTrue);
    });

    test('is false when no role has code FIRM_ADMIN', () {
      final user = buildUser(
        roles: const [
          Role(id: 'r1', code: 'LAWYER', scope: 'TENANT', permissions: []),
        ],
      );

      expect(user.isFirmAdmin, isFalse);
    });

    test('is false for a user with no roles', () {
      expect(buildUser().isFirmAdmin, isFalse);
    });
  });
}
