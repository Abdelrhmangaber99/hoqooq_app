import 'permission_codes.dart';

/// Slicing of the server-provided permission catalog into the Finance
/// display groups used by the employee permission editor (PRD v2.0 §7.8
/// BR-028). The catalog itself stays authoritative — the server decides
/// what the signed-in admin may manage and what exists; these helpers only
/// group the codes for display, keeping Case-level finance
/// (`finance.case.view`, `finance.payment.record`, `finance.manage`)
/// separate from the firm-wide grant (`finance.firm.read`).
abstract final class FinancePermissionGroups {
  static const caseFinance = <String>[
    PermissionCodes.financeCaseView,
    PermissionCodes.financePaymentRecord,
    PermissionCodes.financeManage,
  ];

  static const firmFinance = <String>[PermissionCodes.financeFirmRead];

  static bool isCaseFinance(String code) => caseFinance.contains(code);
  static bool isFirmFinance(String code) => firmFinance.contains(code);
  static bool isFinance(String code) =>
      isCaseFinance(code) || isFirmFinance(code);

  static List<String> caseFinanceOf(Iterable<String> catalog) => catalog
      .where(isCaseFinance)
      .toList(growable: false);

  static List<String> firmFinanceOf(Iterable<String> catalog) => catalog
      .where(isFirmFinance)
      .toList(growable: false);

  static List<String> excludingFinance(Iterable<String> catalog) => catalog
      .where((code) => !isFinance(code))
      .toList(growable: false);
}
