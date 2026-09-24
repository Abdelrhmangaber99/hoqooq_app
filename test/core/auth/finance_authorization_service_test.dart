import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/auth/finance_authorization_service.dart';
import 'package:hqooq/core/auth/permission_codes.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';

void main() {
  group('FinanceAuthorizationService - 12 Security Scenarios', () {
    final now = DateTime.now();

    User createUser({
      required String id,
      String status = 'ACTIVE',
      String accountType = 'EMPLOYEE',
      String? jobClassification = 'ACCOUNTANT',
      List<String> permissions = const [],
      String tenantId = 'tenant-A',
    }) {
      return User(
        id: id,
        email: '$id@example.com',
        fullName: 'User $id',
        isSuperAdmin: false,
        status: status,
        mfaEnabled: false,
        createdAt: now,
        updatedAt: now,
        accountType: accountType,
        jobClassification: jobClassification,
        permissions: permissions,
        tenant: TenantRef(id: tenantId, name: 'Tenant $tenantId'),
      );
    }

    // Scenario 1: Accountant without finance permission -> denied
    test('Scenario 1: Accountant without finance permission -> denied', () {
      final accountant = createUser(
        id: 'acc1',
        jobClassification: 'ACCOUNTANT',
        permissions: [], // No finance.firm.read or finance.case.view
      );

      expect(FinanceAuthorizationService.canViewFirmFinance(accountant), false);
      expect(
        FinanceAuthorizationService.canViewCaseFinance(
          user: accountant,
          caseTenantId: 'tenant-A',
          caseCapabilities: null,
        ),
        false,
      );
    });

    // Scenario 2: Accountant with Case finance.view -> allowed only for that Case
    test('Scenario 2: Accountant with Case finance.view -> allowed only for that Case', () {
      final accountant = createUser(
        id: 'acc2',
        jobClassification: 'ACCOUNTANT',
        permissions: [], // No firm-wide permissions
      );

      // Authorized case
      final canViewCaseA = FinanceAuthorizationService.canViewCaseFinance(
        user: accountant,
        caseTenantId: 'tenant-A',
        caseCapabilities: ['finance.view'],
      );

      // Unauthorized case
      final canViewCaseB = FinanceAuthorizationService.canViewCaseFinance(
        user: accountant,
        caseTenantId: 'tenant-A',
        caseCapabilities: ['case.view'], // no finance capability
      );

      expect(canViewCaseA, true);
      expect(canViewCaseB, false);
    });

    // Scenario 3: Accountant with finance.payment.record -> can record authorized Case payment
    test('Scenario 3: Accountant with finance.payment.record -> can record payment', () {
      final accountantWithPerm = createUser(
        id: 'acc3',
        jobClassification: 'ACCOUNTANT',
        permissions: [PermissionCodes.financePaymentRecord],
      );

      final canRecord = FinanceAuthorizationService.canRecordPayment(
        user: accountantWithPerm,
        caseTenantId: 'tenant-A',
        caseCapabilities: null,
      );

      expect(canRecord, true);
    });

    // Scenario 4: User with finance.firm.read -> firm dashboard allowed
    test('Scenario 4: User with finance.firm.read -> firm dashboard allowed', () {
      final userWithFirmRead = createUser(
        id: 'user4',
        permissions: [PermissionCodes.financeFirmRead],
      );

      expect(FinanceAuthorizationService.canViewFirmFinance(userWithFirmRead), true);
    });

    // Scenario 5: Case-only finance user -> firm dashboard denied
    test('Scenario 5: Case-only finance user -> firm dashboard denied', () {
      final caseOnlyUser = createUser(
        id: 'user5',
        permissions: [PermissionCodes.financeCaseView], // base case view only
      );

      expect(FinanceAuthorizationService.canViewFirmFinance(caseOnlyUser), false);
    });

    // Scenario 6: Revoked Case finance permission -> immediate denial
    test('Scenario 6: Revoked Case finance permission -> immediate denial', () {
      final userWithPermission = createUser(
        id: 'user6',
        permissions: [PermissionCodes.financeCaseView],
      );

      expect(
        FinanceAuthorizationService.canViewCaseFinance(
          user: userWithPermission,
          caseTenantId: 'tenant-A',
          caseCapabilities: null,
        ),
        true,
      );

      // Simulate permission revocation
      final revokedUser = userWithPermission.copyWith(permissions: []);

      expect(
        FinanceAuthorizationService.canViewCaseFinance(
          user: revokedUser,
          caseTenantId: 'tenant-A',
          caseCapabilities: null,
        ),
        false,
      );
    });

    // Scenario 7: Inactive user -> denial
    test('Scenario 7: Inactive user -> denial', () {
      final inactiveUser = createUser(
        id: 'user7',
        status: 'INACTIVE',
        permissions: [PermissionCodes.financeFirmRead, PermissionCodes.financeCaseView],
      );

      expect(FinanceAuthorizationService.canViewFirmFinance(inactiveUser), false);
      expect(
        FinanceAuthorizationService.canViewCaseFinance(
          user: inactiveUser,
          caseTenantId: 'tenant-A',
          caseCapabilities: ['finance.view'],
        ),
        false,
      );
    });

    // Scenario 8: Wrong tenant -> denial
    test('Scenario 8: Wrong tenant -> denial', () {
      final userTenantA = createUser(
        id: 'user8',
        tenantId: 'tenant-A',
        permissions: [PermissionCodes.financeCaseView, PermissionCodes.financePaymentRecord],
      );

      expect(
        FinanceAuthorizationService.canViewCaseFinance(
          user: userTenantA,
          caseTenantId: 'tenant-B', // Cross-tenant
          caseCapabilities: null,
        ),
        false,
      );

      expect(
        FinanceAuthorizationService.canRecordPayment(
          user: userTenantA,
          caseTenantId: 'tenant-B',
          caseCapabilities: null,
        ),
        false,
      );
    });

    // Scenario 9: Unauthorized payment creation -> denial
    test('Scenario 9: Unauthorized payment creation -> denial', () {
      final userWithoutRecordPerm = createUser(
        id: 'user9',
        permissions: [PermissionCodes.financeCaseView], // view only, no record
      );

      expect(
        FinanceAuthorizationService.canRecordPayment(
          user: userWithoutRecordPerm,
          caseTenantId: 'tenant-A',
          caseCapabilities: ['finance.view'], // no record cap
        ),
        false,
      );
    });

    // Scenario 10: Direct API bypass attempt -> still denied at service boundary
    test('Scenario 10: Direct API bypass attempt -> still denied at guard boundary', () {
      final maliciousUser = createUser(
        id: 'user10',
        permissions: [], // No permissions
      );

      // Direct guard invocation mimicking API route execution
      final isAuthorized = FinanceAuthorizationService.canManageFinance(
        user: maliciousUser,
        caseTenantId: 'tenant-A',
      );

      expect(isAuthorized, false);
    });

    // Scenario 11: Frontend-hidden route accessed directly -> backend guard denies
    test('Scenario 11: Frontend-hidden route accessed directly -> guard denies', () {
      final hiddenRouteUser = createUser(
        id: 'user11',
        jobClassification: 'ACCOUNTANT',
        permissions: [], // hidden in UI
      );

      final isFirmDashboardAllowed = FinanceAuthorizationService.canViewFirmFinance(hiddenRouteUser);

      expect(isFirmDashboardAllowed, false);
    });

    // Scenario 12: Firm aggregate cannot include Cases outside effective scope
    test('Scenario 12: Firm aggregate filtering excludes unauthorized cases', () {
      final userWithCaseAOnly = createUser(
        id: 'user12',
        permissions: [],
      );

      final allCases = [
        {'id': 'c1', 'tenantId': 'tenant-A', 'caps': ['finance.view']},
        {'id': 'c2', 'tenantId': 'tenant-A', 'caps': ['case.view']}, // No finance view
        {'id': 'c3', 'tenantId': 'tenant-B', 'caps': ['finance.view']}, // Cross-tenant
      ];

      final filtered = FinanceAuthorizationService.filterAuthorizedCases(
        user: userWithCaseAOnly,
        cases: allCases,
        caseTenantIdOf: (item) => item['tenantId'] as String,
        caseCapabilitiesOf: (item) => (item['caps'] as List).cast<String>(),
      );

      expect(filtered, hasLength(1));
      expect(filtered.first['id'], 'c1');
    });
  });
}
