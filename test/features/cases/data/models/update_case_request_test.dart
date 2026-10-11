import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/cases/data/models/update_case_request.dart';

void main() {
  test('serializes only fields accepted by the deployed UpdateCaseDto', () {
    final request = UpdateCaseRequest(
      title: 'Updated title',
      courtCaseNumber: '1234',
      courtCaseYear: 2026,
      governorateId: 'governorate-1',
      defaultCourtId: 'court-1',
      circuitId: 'circuit-1',
      primaryLawyerId: 'lawyer-1',
      openingDate: DateTime.utc(2026, 8, 15),
      description: 'Updated description',
      agreedFee: 5000,
    );

    expect(request.toJson(), {
      'title': 'Updated title',
      'courtCaseNumber': '1234',
      'courtCaseYear': 2026,
      'governorateId': 'governorate-1',
      'defaultCourtId': 'court-1',
      'circuitId': 'circuit-1',
      'primaryLawyerId': 'lawyer-1',
      'openingDate': '2026-08-15T00:00:00.000Z',
      'description': 'Updated description',
      'agreedFee': 5000.0,
    });
  });

  test('never emits keys the deployed DTO would reject', () {
    // `caseNumber`, `courtName` and `priority` are absent from the deployed
    // UpdateCaseDto; the backend's forbidNonWhitelisted pipe turns any of
    // them into a 400 for the whole request.
    final json = const UpdateCaseRequest().toJson();
    expect(json.keys, isNot(contains('caseNumber')));
    expect(json.keys, isNot(contains('courtName')));
    expect(json.keys, isNot(contains('priority')));
  });

  test('omits every unchanged optional field', () {
    expect(const UpdateCaseRequest().toJson(), isEmpty);
  });
}
