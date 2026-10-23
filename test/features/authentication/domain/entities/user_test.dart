import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';

void main() {
  User buildUser({
    String? accountType,
    String? jobClassification,
    List<String> permissions = const [],
  }) {
    return User(
      id: 'u1',
      email: 'lawyer@firm.com',
      fullName: 'Jane Doe',
      status: 'ACTIVE',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      accountType: accountType,
      jobClassification: jobClassification,
      permissions: permissions,
      tenant: const TenantRef(id: 't1', name: 'Reynolds & Associates'),
    );
  }

  test('fullName is the API-provided value', () {
    expect(buildUser().fullName, 'Jane Doe');
  });

  group('fromJson', () {
    // Regression: HOQOOQ API 3.0.0's `UserResponseDto` (verified from the
    // live `GET /api/docs-json`) dropped `isSuperAdmin` and `mfaEnabled`. Both
    // were `required bool` fields here, so a real response threw
    // "type 'Null' is not a subtype of type 'bool'" inside `_$UserFromJson`
    // — an error `AuthRepository.getCurrentUser()` doesn't catch (it maps
    // `DioException` only), which killed the `AuthBloc` handler and left the
    // sign-in button spinning / the splash screen stuck forever.
    test('parses a v3 GET /users/me payload carrying no isSuperAdmin or '
        'mfaEnabled key', () {
      final user = User.fromJson({
        'id': 'd6b6c71a-d4da-490c-b1e1-d509a1d4ab74',
        'email': 'admin@demo.local',
        'fullName': 'Jane Doe',
        'avatarUrl': null,
        'status': 'ACTIVE',
        'accountType': 'FIRM_ADMIN',
        'jobClassification': null,
        'phone': null,
        'lastLoginAt': null,
        'createdAt': '2026-08-06T01:34:16.880Z',
        'updatedAt': '2026-08-06T01:34:16.880Z',
        'tenant': {'id': 't1', 'name': 'Demo Law Firm'},
        'permissions': ['cases.read'],
      });

      expect(user.id, 'd6b6c71a-d4da-490c-b1e1-d509a1d4ab74');
      expect(user.isActive, isTrue);
      expect(user.isFirmAdmin, isTrue);
      expect(user.isSuperAdmin, isFalse);
      expect(user.phone, isNull);
      expect(user.hasPerm('cases.read'), isTrue);
      expect(user.tenant?.name, 'Demo Law Firm');
    });

    test('tenant is nullable -- a tenant-less platform account must '
        'parse without crashing (confirmed live 2026-08-06)', () {
      final user = User.fromJson({
        'id': 'u1',
        'email': 'admin@hoqooq.local',
        'fullName': 'System Admin',
        'avatarUrl': null,
        'status': 'ACTIVE',
        'accountType': 'SUPER_ADMIN',
        'lastLoginAt': null,
        'createdAt': '2026-08-06T01:34:16.880Z',
        'updatedAt': '2026-08-06T01:34:16.880Z',
        'tenant': null,
      });

      expect(user.tenant, isNull);
      expect(user.isSuperAdmin, isTrue);
    });

    // v2 replaced the roles[]-based permission mechanism with a flat
    // `permissions: List<String>` field -- this asserts a legacy `roles` key
    // in the payload (still sent by some older backend paths) is safely
    // ignored rather than crashing, since `User` no longer declares a `roles`
    // field at all.
    test('ignores a legacy roles[] key in the payload without crashing', () {
      final user = User.fromJson({
        'id': 'd6b6c71a-d4da-490c-b1e1-d509a1d4ab74',
        'email': 'admin@hoqooq.local',
        'fullName': 'System Admin',
        'avatarUrl': null,
        'status': 'ACTIVE',
        'accountType': 'SUPER_ADMIN',
        'lastLoginAt': null,
        'createdAt': '2026-08-06T01:34:16.880Z',
        'updatedAt': '2026-08-06T01:34:16.880Z',
        'roles': [
          {'id': '9c6bf3a5-5684-4152-a252-5b4fc5420adf', 'code': 'SUPER_ADMIN'},
        ],
        'tenant': null,
        'permissions': ['system.tenants.create'],
      });

      expect(user.id, 'd6b6c71a-d4da-490c-b1e1-d509a1d4ab74');
      expect(user.tenant, isNull);
      expect(user.hasPerm('system.tenants.create'), isTrue);
    });
  });

  group('hasPerm', () {
    test('is true when an explicit v2 account permission matches', () {
      expect(
        buildUser(permissions: const ['case.view']).hasPerm('case.view'),
        isTrue,
      );
    });

    test('is false when no permission matches', () {
      expect(buildUser().hasPerm('cases.read'), isFalse);
    });
  });

  group('isFirmAdmin', () {
    test('is true only for the v2 FIRM_ADMIN account type', () {
      final user = buildUser(accountType: 'FIRM_ADMIN');

      expect(user.isFirmAdmin, isTrue);
    });

    test('is false for an Employee account', () {
      final user = buildUser(accountType: 'EMPLOYEE');

      expect(user.isFirmAdmin, isFalse);
    });

    test('is false when accountType is unset', () {
      expect(buildUser().isFirmAdmin, isFalse);
    });
  });

  group('isSuperAdmin', () {
    test('is true only for the SUPER_ADMIN account type', () {
      expect(buildUser(accountType: 'SUPER_ADMIN').isSuperAdmin, isTrue);
    });

    test('is false for firm accounts and when accountType is unset', () {
      expect(buildUser(accountType: 'FIRM_ADMIN').isSuperAdmin, isFalse);
      expect(buildUser(accountType: 'EMPLOYEE').isSuperAdmin, isFalse);
      expect(buildUser().isSuperAdmin, isFalse);
    });
  });

  test('uses professional classification only for professional helpers', () {
    final user = buildUser(
      accountType: 'EMPLOYEE',
      jobClassification: 'LAWYER',
    );

    expect(user.isEmployee, isTrue);
    expect(user.isLawyer, isTrue);
    expect(user.hasPerm('finance.firm.view'), isFalse);
  });
}
