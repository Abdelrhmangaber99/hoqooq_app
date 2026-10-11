import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/employees/data/models/employee_summary.dart';

void main() {
  group('EmployeeSummary', () {
    test('parses full employee JSON with nested user and position', () {
      final json = {
        'id': 'emp-101',
        'position': 'SENIOR_PARALEGAL',
        'user': {
          'fullName': 'Amina Al-Mansoor',
          'email': 'amina@firm.test',
        },
      };

      final summary = EmployeeSummary.fromJson(json);

      expect(summary.id, 'emp-101');
      expect(summary.name, 'Amina Al-Mansoor');
      expect(summary.email, 'amina@firm.test');
      expect(summary.positionLabel, 'Senior Paralegal');
    });

    test('handles missing or malformed nested fields safely', () {
      final json = <String, dynamic>{
        'id': 505,
        'user': 'invalid_user_type',
      };

      final summary = EmployeeSummary.fromJson(json);

      expect(summary.id, '505');
      expect(summary.name, '');
      expect(summary.email, '');
      expect(summary.positionLabel, '');
    });

    test('parses status and userId from employee JSON', () {
      final json = {
        'id': 'emp-102',
        'status': 'INACTIVE',
        'userId': 'usr-202',
        'position': 'LAWYER',
        'user': {
          'id': 'usr-202',
          'fullName': 'Tariq Hassan',
          'email': 'tariq@firm.test',
          'status': 'INACTIVE',
        },
      };

      final summary = EmployeeSummary.fromJson(json);

      expect(summary.id, 'emp-102');
      expect(summary.status, 'INACTIVE');
      expect(summary.userId, 'usr-202');
      expect(summary.isActive, false);
    });

    test('humanize correctly formats various underscore position formats', () {
      expect(EmployeeSummary.humanize('JUNIOR_ASSOCIATE'), 'Junior Associate');
      expect(EmployeeSummary.humanize('LAWYER'), 'Lawyer');
      expect(EmployeeSummary.humanize('LEGAL_CONSULTANT_EXPERT'), 'Legal Consultant Expert');
      expect(EmployeeSummary.humanize(''), '');
    });
  });
}
