import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/service_of_process/data/models/create_service_process_request.dart';
import 'package:hqooq/features/service_of_process/data/models/complete_service_process_request.dart';
import 'package:hqooq/features/service_of_process/domain/entities/service_status.dart';

void main() {
  group('CreateServiceProcessRequest', () {
    test('serializes required fields and optional court/notes', () {
      final request = CreateServiceProcessRequest(
        caseId: 'c1',
        targetName: 'Defendant John Doe',
        serviceMethodId: 'm1',
        scheduledAt: DateTime.utc(2026, 9, 22, 9, 0),
        courtId: 'court-1',
        notes: 'Hand deliver at workplace',
      );

      final json = request.toJson();

      expect(json['caseId'], 'c1');
      expect(json['targetName'], 'Defendant John Doe');
      expect(json['serviceMethodId'], 'm1');
      expect(json['scheduledAt'], '2026-09-22T09:00:00.000Z');
      expect(json['courtId'], 'court-1');
      expect(json['notes'], 'Hand deliver at workplace');
    });
  });

  group('CompleteServiceProcessRequest', () {
    test('serializes only the deployed completion DTO fields', () {
      const request = CompleteServiceProcessRequest(
        status: ServiceStatus.completed,
        resultNotes: 'Served successfully to recipient',
      );

      final json = request.toJson();

      expect(json['status'], 'SERVED');
      expect(json['resultNotes'], 'Served successfully to recipient');
      expect(json.containsKey('documentId'), isFalse);
    });
  });
}
