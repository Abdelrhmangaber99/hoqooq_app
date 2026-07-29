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
      firstName: 'Jane',
      lastName: 'Doe',
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      roles: roles,
      tenant: const TenantRef(id: 't1', name: 'Reynolds & Associates'),
    );
  }

  test('fullName concatenates firstName and lastName', () {
    expect(buildUser().fullName, 'Jane Doe');
  });

  group('hasPerm', () {
    test('is true when any role grants the exact resource/action pair', () {
      final user = buildUser(
        roles: [
          Role(
            id: 'r1',
            name: 'LAWYER',
            displayNameEn: 'Lawyer',
            displayNameAr: 'محامي',
            permissions: const [
              Permission(
                id: 'p1',
                resource: 'cases',
                action: 'read',
                displayNameEn: 'Read cases',
                displayNameAr: 'قراءة القضايا',
              ),
            ],
          ),
        ],
      );

      expect(user.hasPerm('cases', 'read'), isTrue);
    });

    test('is false when no role grants the pair', () {
      expect(buildUser().hasPerm('cases', 'read'), isFalse);
    });

    test('does not match on resource alone without the right action', () {
      final user = buildUser(
        roles: [
          Role(
            id: 'r1',
            name: 'LAWYER',
            displayNameEn: 'Lawyer',
            displayNameAr: 'محامي',
            permissions: const [
              Permission(
                id: 'p1',
                resource: 'cases',
                action: 'read',
                displayNameEn: 'Read cases',
                displayNameAr: 'قراءة القضايا',
              ),
            ],
          ),
        ],
      );

      expect(user.hasPerm('cases', 'delete'), isFalse);
    });
  });

  test(
    'isFirmAdmin is always false for now (no confirmed role.name value — see CLAUDE.md)',
    () {
      expect(buildUser().isFirmAdmin, isFalse);
    },
  );
}
