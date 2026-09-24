import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/cases/domain/entities/case_capability.dart';

void main() {
  User userWith(List<String> permissions) => User(
    id: 'u1',
    email: 'admin@firm.test',
    fullName: 'Firm Admin',
    isSuperAdmin: false,
    status: 'ACTIVE',
    mfaEnabled: false,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    permissions: permissions,
  );

  test('catalog mirrors all backend Case capabilities without duplicates', () {
    expect(CaseCapabilities.definitions, hasLength(36));
    expect(
      CaseCapabilities.definitions.map((item) => item.code).toSet(),
      hasLength(36),
    );
  });

  test('only capabilities backed by the delegator permissions are offered', () {
    final capabilities = CaseCapabilities.delegableBy(
      userWith(['case.view', 'document.upload']),
    ).map((item) => item.code);

    expect(capabilities, containsAll(['case.view', 'document.upload']));
    expect(capabilities, isNot(contains('case.edit')));
  });

  test('finance capabilities are offered and delegable like any other', () {
    final capabilities = CaseCapabilities.delegableBy(
      userWith([
        'finance.case.view',
        'finance.payment.record',
        'finance.manage',
      ]),
    ).map((item) => item.code);

    expect(
      capabilities,
      containsAll([
        'finance.case.view',
        'finance.payment.record',
        'finance.manage',
      ]),
    );
  });

  test('firm-wide finance is not a case capability', () {
    final codes = CaseCapabilities.definitions.map((item) => item.code);
    expect(codes, isNot(contains('finance.firm.read')));
  });

  test('finance capabilities sit in their own group, selectable independently',
      () {
    final financeDefs = CaseCapabilities.definitions
        .where((item) => item.group == CaseCapabilityGroup.finance)
        .map((item) => item.code);

    expect(
      financeDefs,
      equals(['finance.case.view', 'finance.payment.record', 'finance.manage']),
    );
  });
}
