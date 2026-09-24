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
}
