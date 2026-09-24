import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/cases/domain/entities/legal_case.dart';

void main() {
  const baseJson = <String, dynamic>{
    'id': 'case-1',
    'tenantId': 'tenant-1',
    'caseNumber': 'CASE-2026-1',
    'status': 'DRAFT',
    'priority': 'NORMAL',
    'createdAt': '2026-08-15T00:00:00.000Z',
    'updatedAt': '2026-08-15T00:00:00.000Z',
  };

  test('parses authoritative case-local client and opponent snapshots', () {
    final legalCase = LegalCase.fromJson({
      ...baseJson,
      'title': 'Contract dispute',
      'courtName': 'Cairo Court of Appeal',
      'clientSnapshot': const {
        'id': 'client-snapshot-1',
        'clientType': 'COMPANY',
        'name': 'Acme LLC',
        'registrationNo': 'REG-1',
      },
      'opponentSnapshots': const [
        {
          'id': 'opponent-snapshot-1',
          'opponentType': 'INDIVIDUAL',
          'name': 'Jane Doe',
          'contact': '01000000000',
        },
      ],
    });

    expect(legalCase.title, 'Contract dispute');
    expect(legalCase.courtName, 'Cairo Court of Appeal');
    expect(legalCase.clientSnapshot?.name, 'Acme LLC');
    expect(legalCase.opponentSnapshots, hasLength(1));
    expect(legalCase.opponentSnapshots?.single.name, 'Jane Doe');
  });

  test('preserves omitted snapshots as unavailable', () {
    final legalCase = LegalCase.fromJson(baseJson);

    expect(legalCase.clientSnapshot, isNull);
    expect(legalCase.opponentSnapshots, isNull);
  });

  test('parses embedded Case timeline events defensively', () {
    final legalCase = LegalCase.fromJson({
      ...baseJson,
      'timelineEvents': const [
        {
          'id': 'event-1',
          'caseId': 'case-1',
          'eventType': 'STATUS_CHANGED',
          'actorUserId': 'user-1',
          'previousState': 'DRAFT',
          'newState': 'ACTIVE',
          'note': 'Case status changed',
          'createdAt': '2026-08-16T10:00:00.000Z',
        },
      ],
    });

    expect(legalCase.timelineEvents, hasLength(1));
    expect(legalCase.timelineEvents!.single.previousState, 'DRAFT');
    expect(legalCase.timelineEvents!.single.newState, 'ACTIVE');
  });
}
