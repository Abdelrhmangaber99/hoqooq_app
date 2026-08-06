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

  group('fromJson', () {
    test('tenant is nullable -- a tenant-less SUPER_ADMIN account must '
        'parse without crashing (confirmed live 2026-08-06)', () {
      final user = User.fromJson({
        'id': 'u1',
        'email': 'admin@hoqooq.local',
        'fullName': 'System Admin',
        'avatarUrl': null,
        'isSuperAdmin': true,
        'status': 'ACTIVE',
        'mfaEnabled': false,
        'lastLoginAt': null,
        'createdAt': '2026-08-06T01:34:16.880Z',
        'updatedAt': '2026-08-06T01:34:16.880Z',
        'roles': const [],
        'tenant': null,
      });

      expect(user.tenant, isNull);
    });

    // Full regression test for the real GET /users/me response captured
    // live 2026-08-06 (curl against a fresh login) -- previously crashed
    // with "type 'Null' is not a subtype of type 'List<dynamic>'" in
    // Role.fromJson, then would have crashed a second time on `tenant`
    // once that was fixed. Reproduces both real quirks at once: roles[]
    // nests the raw entity (rolePermissions, not permissions; extra
    // BaseEntity columns), and tenant is null.
    test('parses the real GET /users/me shape without crashing', () {
      final user = User.fromJson({
        'id': 'd6b6c71a-d4da-490c-b1e1-d509a1d4ab74',
        'email': 'admin@hoqooq.local',
        'fullName': 'System Admin',
        'avatarUrl': null,
        'isSuperAdmin': true,
        'status': 'ACTIVE',
        'mfaEnabled': false,
        'lastLoginAt': null,
        'createdAt': '2026-08-06T01:34:16.880Z',
        'updatedAt': '2026-08-06T01:34:16.880Z',
        'roles': [
          {
            'id': '9c6bf3a5-5684-4152-a252-5b4fc5420adf',
            'createdAt': '2026-08-06T01:34:16.654Z',
            'updatedAt': '2026-08-06T01:34:16.654Z',
            'archivedAt': null,
            'isArchived': false,
            'code': 'SUPER_ADMIN',
            'scope': 'SYSTEM',
            'tenantId': null,
            'rolePermissions': [
              {
                'roleId': '9c6bf3a5-5684-4152-a252-5b4fc5420adf',
                'permissionId': '4c7cf8cc-3cc3-4e29-813c-7032fd221da1',
                'permission': {
                  'id': '4c7cf8cc-3cc3-4e29-813c-7032fd221da1',
                  'createdAt': '2026-08-06T01:34:16.649Z',
                  'updatedAt': '2026-08-06T01:34:16.649Z',
                  'archivedAt': null,
                  'isArchived': false,
                  'code': 'system.tenants.create',
                },
              },
            ],
          },
        ],
        'tenant': null,
        'permissions': ['undefined.undefined'],
      });

      expect(user.id, 'd6b6c71a-d4da-490c-b1e1-d509a1d4ab74');
      expect(user.tenant, isNull);
      expect(user.roles, hasLength(1));
      expect(user.roles.single.code, 'SUPER_ADMIN');
      expect(user.hasPerm('system.tenants.create'), isTrue);
    });
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
