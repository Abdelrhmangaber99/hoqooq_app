import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/cases/data/models/update_case_request.dart';
import 'package:hqooq/features/cases/domain/entities/case_priority.dart';

void main() {
  test('serializes only fields accepted by the v2 UpdateCaseDto', () {
    final request = UpdateCaseRequest(
      title: 'Updated title',
      courtCaseNumber: '1234',
      courtCaseYear: 2026,
      governorateId: 'governorate-1',
      defaultCourtId: 'court-1',
      circuitId: 'circuit-1',
      courtName: 'Cairo Court of Appeal',
      primaryLawyerId: 'lawyer-1',
      openingDate: DateTime.utc(2026, 8, 15),
      description: 'Updated description',
      agreedFee: 5000,
      priority: CasePriority.high,
    );

    expect(request.toJson(), {
      'title': 'Updated title',
      'courtCaseNumber': '1234',
      'courtCaseYear': 2026,
      'governorateId': 'governorate-1',
      'defaultCourtId': 'court-1',
      'circuitId': 'circuit-1',
      'courtName': 'Cairo Court of Appeal',
      'primaryLawyerId': 'lawyer-1',
      'openingDate': '2026-08-15T00:00:00.000Z',
      'description': 'Updated description',
      'agreedFee': 5000.0,
      'priority': 'HIGH',
    });
  });

  test('omits every unchanged optional field', () {
    expect(const UpdateCaseRequest().toJson(), isEmpty);
  });
}
