import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/authentication/domain/entities/role.dart';

void main() {
  group('Role.fromJson', () {
    test('uses a clean permissions list when the backend sends one', () {
      final role = Role.fromJson({
        'id': 'r1',
        'code': 'LAWYER',
        'scope': 'TENANT',
        'permissions': [
          {'id': 'p1', 'code': 'cases.read'},
        ],
      });

      expect(role.permissions, hasLength(1));
      expect(role.permissions.single.code, 'cases.read');
    });

    // Real shape confirmed live 2026-08-06 against GET /users/me: no
    // `permissions` key at all -- UsersController's plainToInstance does
    // not apply RoleResponseDto's own @Expose/@Transform rules to nested
    // roles, so the raw entity (including the rolePermissions join array
    // and BaseEntity columns) leaks through instead.
    test('derives permissions from rolePermissions[].permission when '
        'permissions is absent', () {
      final role = Role.fromJson({
        'id': 'r1',
        'createdAt': '2026-08-06T01:34:16.654Z',
        'updatedAt': '2026-08-06T01:34:16.654Z',
        'archivedAt': null,
        'isArchived': false,
        'code': 'SUPER_ADMIN',
        'scope': 'SYSTEM',
        'tenantId': null,
        'rolePermissions': [
          {
            'roleId': 'r1',
            'permissionId': 'p1',
            'permission': {
              'id': 'p1',
              'createdAt': '2026-08-06T01:34:16.649Z',
              'updatedAt': '2026-08-06T01:34:16.649Z',
              'archivedAt': null,
              'isArchived': false,
              'code': 'system.tenants.create',
            },
          },
          {
            'roleId': 'r1',
            'permissionId': 'p2',
            'permission': {'id': 'p2', 'code': 'system.tenants.read'},
          },
        ],
      });

      expect(role.id, 'r1');
      expect(role.code, 'SUPER_ADMIN');
      expect(role.scope, 'SYSTEM');
      expect(role.permissions, hasLength(2));
      expect(
        role.permissions.map((p) => p.code),
        containsAll(['system.tenants.create', 'system.tenants.read']),
      );
    });

    // Real shape confirmed from GET /roles: RolesController queries with
    // an explicit `select: ['id', 'code', 'scope']` -- neither
    // `permissions` nor `rolePermissions` is present at all.
    test('defaults to an empty list when neither permissions nor '
        'rolePermissions is present', () {
      final role = Role.fromJson({
        'id': 'r1',
        'code': 'LAWYER',
        'scope': 'TENANT',
      });

      expect(role.permissions, isEmpty);
    });
  });
}
