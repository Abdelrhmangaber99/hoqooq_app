import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/platform_admin/domain/platform_admin_contract.dart';

void main() {
  test('parses the permission catalog object and sorts codes', () {
    expect(
      PlatformAdminContract.permissionCodes({
        'codes': ['employee.read', 'case.view'],
      }),
      ['case.view', 'employee.read'],
    );
  });

  test('selects only the current non-archived subscription', () {
    final current = PlatformAdminContract.currentSubscription({
      'subscriptions': [
        {'id': 'old', 'supersededAt': '2026-01-01T00:00:00Z'},
        {'id': 'archived', 'supersededAt': null, 'isArchived': true},
        {'id': 'current', 'supersededAt': null, 'isArchived': false},
      ],
    });

    expect(current?['id'], 'current');
  });

  test('parses the tenant platform-overview envelope', () {
    final response = {
      'firm': {'id': 'firm-1', 'status': 'ACTIVE'},
      'employees': [
        {'id': 'user-1', 'status': 'INACTIVE'},
      ],
      'currentSubscription': {'status': 'EXPIRED'},
    };

    expect(PlatformAdminContract.overviewFirm(response)['id'], 'firm-1');
    expect(
      PlatformAdminContract.overviewEmployees(response).single['status'],
      'INACTIVE',
    );
    expect(
      PlatformAdminContract.overviewSubscription(response)?['status'],
      'EXPIRED',
    );
  });

  test('unwraps the deployed firm registry row', () {
    // Live shape of GET /tenants and GET /tenants/:id on the deployed API
    // (verified 2026-10-11): one {firm, firmAdmin, currentSubscription} per
    // firm, with the Firm Admin embedded rather than listed separately.
    final firm = PlatformAdminContract.normalizeTenant({
      'firm': {'id': 'firm-1', 'name': 'North Law', 'status': 'ACTIVE'},
      'firmAdmin': {
        'id': 'admin-1',
        'fullName': 'North Admin',
        'email': 'admin@north.test',
        'status': 'ACTIVE',
      },
      'currentSubscription': {
        'status': 'ACTIVE',
        'plan': {'name': 'Professional'},
      },
    });

    expect(firm['id'], 'firm-1');
    expect(firm['name'], 'North Law');
    expect((firm['firmAdmin'] as Map)['id'], 'admin-1');
    expect(PlatformAdminContract.currentSubscription(firm)?['status'], 'ACTIVE');
  });

  test('collection unwraps the deployed firm registry list', () {
    final firms = PlatformAdminContract.collection([
      {
        'firm': {'id': 'firm-1', 'name': 'North Law'},
        'firmAdmin': {'id': 'admin-1'},
      },
      {
        'firm': {'id': 'firm-2', 'name': 'South Law'},
        'firmAdmin': {'id': 'admin-2'},
      },
    ]);

    expect(firms.map((firm) => firm['id']), ['firm-1', 'firm-2']);
    expect((firms.first['firmAdmin'] as Map)['id'], 'admin-1');
  });

  test('filters platform users to the selected firm', () {
    final users = PlatformAdminContract.usersForFirm(
      {
        'items': [
          {
            'id': 'admin-1',
            'tenant': {'id': 'firm-1'},
          },
          {'id': 'admin-2', 'tenantId': 'firm-2'},
        ],
      },
      'firm-1',
    );

    expect(users.map((user) => user['id']), ['admin-1']);
  });
}
