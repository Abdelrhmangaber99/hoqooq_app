import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/auth/finance_permission_groups.dart';
import 'package:hqooq/core/auth/permission_codes.dart';

void main() {
  group('finance permission grouping (employee permission editor)', () {
    // Shape of the server-provided catalog (`GET /permissions` → codes).
    // The server stays authoritative; these tests pin the grouping rules.
    const catalog = <String>[
      'case.view',
      'case.edit',
      'document.view',
      'document.upload',
      PermissionCodes.financeCaseView,
      PermissionCodes.financePaymentRecord,
      PermissionCodes.financeManage,
      PermissionCodes.financeFirmRead,
    ];

    test('case-level finance permissions are sliced into their own group',
        () {
      final codes = FinancePermissionGroups.caseFinanceOf(catalog);
      expect(codes, [
        PermissionCodes.financeCaseView,
        PermissionCodes.financePaymentRecord,
        PermissionCodes.financeManage,
      ]);
    });

    test('firm-level finance permission is a separate single entry', () {
      final codes = FinancePermissionGroups.firmFinanceOf(catalog);
      expect(codes, [PermissionCodes.financeFirmRead]);
    });

    test('general list excludes all finance permissions', () {
      final codes = FinancePermissionGroups.excludingFinance(catalog);
      expect(codes, containsAll(['case.view', 'document.upload']));
      expect(codes, isNot(contains(PermissionCodes.financeCaseView)));
      expect(codes, isNot(contains(PermissionCodes.financePaymentRecord)));
      expect(codes, isNot(contains(PermissionCodes.financeManage)));
      expect(codes, isNot(contains(PermissionCodes.financeFirmRead)));
    });

    test('case finance and firm finance never overlap', () {
      final caseFinance = FinancePermissionGroups.caseFinanceOf(catalog);
      final firmFinance = FinancePermissionGroups.firmFinanceOf(catalog);
      expect(caseFinance.toSet().intersection(firmFinance.toSet()), isEmpty);
    });

    test('case-finance grants work without any other permission', () {
      // An employee can receive finance.view + finance.payment.record
      // without document.view — finance codes carry no implicit bundle of
      // other permissions.
      final codes = FinancePermissionGroups.caseFinanceOf(catalog);
      expect(codes, isNot(contains('document.view')));
      expect(codes, isNot(contains('case.view')));
    });

    test('accountant classification appears nowhere in the grouping rules',
        () {
      // BR-028: job classification never grants finance access, so no
      // grouping rule may reference it — only explicit codes matter.
      const allRules = [...FinancePermissionGroups.caseFinance,
        ...FinancePermissionGroups.firmFinance];
      expect(allRules, everyElement(contains('.')));
      expect(
        allRules,
        everyElement(
          anyOf(
            startsWith('finance.view'),
            startsWith('finance.payment.'),
            startsWith('finance.manage'),
            startsWith('finance.firm.'),
          ),
        ),
      );
    });
  });
}
