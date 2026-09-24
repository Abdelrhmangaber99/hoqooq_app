import '../../features/authentication/domain/entities/user.dart';
import 'permission_codes.dart';

/// Pure domain authorization guard service for HOQOOQ Finance (PRD v2.0).
/// Security boundary logic ensuring RBAC and tenancy checks are strictly enforced.
class FinanceAuthorizationService {
  FinanceAuthorizationService._();

  /// Check if user is allowed to view firm-wide finance dashboard.
  /// PRD Rule: ACCOUNTANT job classification alone MUST NOT grant access automatically.
  /// Requires active account, matched tenant, and explicit `finance.firm.read` permission.
  static bool canViewFirmFinance(User? user) {
    if (user == null || !user.isActive) {
      return false;
    }

    if (user.isSuperAdmin || user.isFirmAdmin) {
      return true;
    }

    return user.hasPerm(PermissionCodes.financeFirmRead);
  }

  /// Check if user can view financial details for a specific Case.
  static bool canViewCaseFinance({
    required User? user,
    required String? caseTenantId,
    required List<String>? caseCapabilities,
  }) {
    if (user == null || !user.isActive) {
      return false;
    }

    // Tenancy check: cross-tenant access prohibited
    if (!user.isSuperAdmin) {
      final userTenantId = user.tenant?.id;
      if (userTenantId == null || caseTenantId == null || userTenantId != caseTenantId) {
        return false;
      }
    }

    if (user.isSuperAdmin || user.isFirmAdmin) {
      return true;
    }

    if (user.hasPerm(PermissionCodes.financeFirmRead)) {
      return true;
    }

    final hasBasePerm = user.hasPerm(PermissionCodes.financeCaseView);

    if (caseCapabilities != null) {
      final hasCaseCap = caseCapabilities.contains(PermissionCodes.financeCaseView) ||
          caseCapabilities.contains('finance.view');
      return hasBasePerm || hasCaseCap;
    }

    return hasBasePerm;
  }

  /// Check if user can record a payment for a specific Case.
  static bool canRecordPayment({
    required User? user,
    required String? caseTenantId,
    required List<String>? caseCapabilities,
  }) {
    if (user == null || !user.isActive) {
      return false;
    }

    if (!user.isSuperAdmin) {
      final userTenantId = user.tenant?.id;
      if (userTenantId == null || caseTenantId == null || userTenantId != caseTenantId) {
        return false;
      }
    }

    if (user.isSuperAdmin || user.isFirmAdmin) {
      return true;
    }

    final hasBasePerm = user.hasPerm(PermissionCodes.financePaymentRecord);

    if (caseCapabilities != null) {
      final hasCaseCap = caseCapabilities.contains(PermissionCodes.financePaymentRecord);
      return hasBasePerm || hasCaseCap;
    }

    return hasBasePerm;
  }

  /// Check if user can perform finance management (e.g. reverse payment).
  static bool canManageFinance({
    required User? user,
    required String? caseTenantId,
  }) {
    if (user == null || !user.isActive) {
      return false;
    }

    if (!user.isSuperAdmin) {
      final userTenantId = user.tenant?.id;
      if (userTenantId == null || caseTenantId == null || userTenantId != caseTenantId) {
        return false;
      }
    }

    if (user.isSuperAdmin || user.isFirmAdmin) {
      return true;
    }

    return user.hasPerm(PermissionCodes.financeManage);
  }

  /// Filter firm summary case rows to only include cases the user is authorized to view.
  static List<T> filterAuthorizedCases<T>({
    required User? user,
    required List<T> cases,
    required String Function(T item) caseTenantIdOf,
    required List<String> Function(T item)? caseCapabilitiesOf,
  }) {
    if (user == null || !user.isActive) {
      return [];
    }

    if (user.isSuperAdmin || user.isFirmAdmin || user.hasPerm(PermissionCodes.financeFirmRead)) {
      return cases.where((item) {
        final tenantId = caseTenantIdOf(item);
        return user.isSuperAdmin || user.tenant?.id == tenantId;
      }).toList();
    }

    return cases.where((item) {
      final tenantId = caseTenantIdOf(item);
      final caps = caseCapabilitiesOf != null ? caseCapabilitiesOf(item) : null;
      return canViewCaseFinance(
        user: user,
        caseTenantId: tenantId,
        caseCapabilities: caps,
      );
    }).toList();
  }
}
