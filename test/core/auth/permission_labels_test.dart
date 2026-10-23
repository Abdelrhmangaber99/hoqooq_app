import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/auth/permission_codes.dart';
import 'package:hqooq/core/auth/permission_labels.dart';

void main() {
  group('deployed v3 permission codes', () {
    // Regression pin. The app shipped the v2 spellings of these seven codes,
    // so an Employee granted everything through the deployed admin UI still
    // saw only the ungated sidebar entries — every gate compared a string the
    // account never held. Verified against the deployed backend
    // (`13.50.240.246:3006`) two independent ways on 2026-10-16: its OpenAPI
    // document (`SetFirmAdminPermissionsDto.permissionKeys.example` is
    // `["case.view","employee.view"]`) and the shipped desktop bundle, whose
    // sidebar map and permission labels name `employee.view`,
    // `employee.manage`, `finance.firm.view`, `finance.view`, `report.view` and
    // `audit.view`.
    test('the seven renamed codes use the deployed spellings', () {
      expect(PermissionCodes.employeeRead, 'employee.view');
      expect(PermissionCodes.employeeEdit, 'employee.manage');
      expect(PermissionCodes.employeePermissionManage, 'employee.manage');
      expect(PermissionCodes.financeFirmRead, 'finance.firm.view');
      expect(PermissionCodes.financeCaseView, 'finance.view');
      expect(PermissionCodes.reportOperationalRead, 'report.view');
      expect(PermissionCodes.auditRead, 'audit.view');
    });

    test('the codes both generations agree on have not drifted', () {
      expect(PermissionCodes.caseView, 'case.view');
      expect(PermissionCodes.caseCreate, 'case.create');
      expect(PermissionCodes.clientView, 'client.view');
      expect(PermissionCodes.hearingView, 'hearing.view');
      expect(PermissionCodes.taskView, 'task.view');
      expect(PermissionCodes.taskUpdate, 'task.update');
      expect(PermissionCodes.taskComplete, 'task.complete');
      expect(PermissionCodes.calendarRead, 'calendar.read');
      expect(PermissionCodes.dashboardRead, 'dashboard.read');
      expect(PermissionCodes.firmProfileRead, 'firm.profile.read');
    });

    test('the v2 spellings still resolve, so an older catalog is handled', () {
      const renamed = <String, String>{
        'employee.read': 'employee.view',
        'employee.edit': 'employee.manage',
        'employee.permission.manage': 'employee.manage',
        'finance.firm.read': 'finance.firm.view',
        'finance.case.view': 'finance.view',
        'report.operational.read': 'report.view',
        'audit.read': 'audit.view',
      };
      for (final entry in renamed.entries) {
        expect(canonicalPermissionCode(entry.key), entry.value);
      }
    });
  });

  group('normalizePermissionCodes', () {
    test('preserves order and passes canonical codes through unchanged', () {
      expect(normalizePermissionCodes(['case.view', 'case.edit']), [
        'case.view',
        'case.edit',
      ]);
    });

    test('removes exact duplicates a re-seed or bad catalog may produce', () {
      expect(
        normalizePermissionCodes(['case.view', 'case.view', 'case.edit']),
        ['case.view', 'case.edit'],
      );
    });

    test('collapses legacy and current codes for one capability into one row, '
        'preferring the current code when it is present', () {
      expect(
        normalizePermissionCodes([
          'employee.read',
          'employees.read',
          'users.read',
        ]),
        ['employee.read'],
      );
      expect(
        normalizePermissionCodes(['finance.payment.record', 'finance.create']),
        ['finance.payment.record'],
      );
    });

    test('never manufactures a code the caller does not hold', () {
      // The server validates a grant against the exact stored code, so when
      // only the legacy form is present the legacy form must be returned.
      expect(normalizePermissionCodes(['employees.read']), ['employees.read']);
      expect(normalizePermissionCodes(['finance.create']), ['finance.create']);
      expect(normalizePermissionCodes(['settings.update', 'settings.create']), [
        'settings.update',
      ]);
    });

    test('every returned code appeared in the input', () {
      final input = <String>[
        'employees.read',
        'employee.edit',
        'users.read',
        'cases.create',
        'case.view',
      ];
      for (final code in normalizePermissionCodes(input)) {
        expect(input, contains(code));
      }
    });

    test('drops blank entries', () {
      expect(normalizePermissionCodes(['', '  ', 'case.view']), ['case.view']);
    });

    test('knownPermissionCodes contains no duplicates', () {
      expect(knownPermissionCodes.toSet().length, knownPermissionCodes.length);
    });
  });
}
