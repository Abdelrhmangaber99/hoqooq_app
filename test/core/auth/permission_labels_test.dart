import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/auth/permission_labels.dart';

void main() {
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
