import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/cases/domain/entities/case_access_level.dart';
import 'package:hqooq/features/cases/domain/entities/case_team_member.dart';

void main() {
  test('parses the compact team member returned from v2 access grants', () {
    final member = CaseTeamMember.fromJson(const {
      'id': 'employee-1',
      'accessLevel': 'GRANTED',
      'roleOnCase': 'case.view',
      'user': {'id': 'employee-1', 'fullName': 'Mona Ali'},
    });

    expect(member.id, 'employee-1');
    expect(member.userId, 'employee-1');
    expect(member.accessLevel, CaseAccessLevel.unknown);
    expect(member.user?.fullName, 'Mona Ali');
    expect(member.user?.isEmployee, isTrue);
  });
}
