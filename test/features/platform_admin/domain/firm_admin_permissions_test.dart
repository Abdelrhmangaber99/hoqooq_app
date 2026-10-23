import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/platform_admin/domain/firm_admin_permissions.dart';

void main() {
  test('only tenant business permissions are grantable to a Firm Admin', () {
    expect(isFirmAdminGrantablePermission('case.view'), isTrue);
    expect(isFirmAdminGrantablePermission('finance.firm.view'), isTrue);
    expect(
      isFirmAdminGrantablePermission('platform.subscription.manage'),
      isFalse,
    );
    expect(isFirmAdminGrantablePermission('system.tenants.read'), isFalse);
  });
}
