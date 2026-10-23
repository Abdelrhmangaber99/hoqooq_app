import 'permission_codes.dart';
import 'permission_labels.dart';

/// Slicing of the server-provided permission catalog into the Finance
/// display groups used by the employee permission editor (PRD v2.0 §7.8
/// BR-028). The catalog itself stays authoritative — the server decides
/// what the signed-in admin may manage and what exists; these helpers only
/// group the codes for display, keeping Case-level finance
/// (`finance.view`, `finance.payment.record`, `finance.manage`) separate
/// from the firm-wide grant (`finance.firm.view`).
///
/// Membership is decided on the **canonical** code, so a catalog that still
/// carries the v2 spellings (`finance.case.view` / `finance.firm.read`)
/// groups — and, more importantly, is still offered as grantable — exactly
/// like the v3 one. The list returned is always the server's own strings,
/// never a canonical substitute: `PATCH /employees/:id/permissions` validates
/// a grant against the exact code the backend stores.
abstract final class FinancePermissionGroups {
  static const caseFinance = <String>[
    PermissionCodes.financeCaseView,
    PermissionCodes.financePaymentRecord,
    PermissionCodes.financeManage,
  ];

  static const firmFinance = <String>[PermissionCodes.financeFirmRead];

  static bool isCaseFinance(String code) =>
      caseFinance.contains(canonicalPermissionCode(code));

  static bool isFirmFinance(String code) =>
      firmFinance.contains(canonicalPermissionCode(code));

  static bool isFinance(String code) =>
      isCaseFinance(code) || isFirmFinance(code);

  static List<String> caseFinanceOf(Iterable<String> catalog) =>
      catalog.where(isCaseFinance).toList(growable: false);

  static List<String> firmFinanceOf(Iterable<String> catalog) =>
      catalog.where(isFirmFinance).toList(growable: false);

  static List<String> excludingFinance(Iterable<String> catalog) =>
      catalog.where((code) => !isFinance(code)).toList(growable: false);
}
