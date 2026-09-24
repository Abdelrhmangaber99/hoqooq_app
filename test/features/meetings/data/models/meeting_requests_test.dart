import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/meetings/data/models/meeting_requests.dart';

void main() {
  group('CreateMeetingRequest', () {
    test('serializes required fields and optional notes correctly', () {
      final request = CreateMeetingRequest(
        caseId: 'c101',
        scheduledAt: DateTime.utc(2026, 9, 25, 14, 30),
        locationOrMethod: 'Conference Room B',
        subject: 'Pre-trial strategy discussion',
        notes: 'Bring client contract documents',
      );

      final json = request.toJson();

      expect(json['caseId'], 'c101');
      expect(json['scheduledAt'], '2026-09-25T14:30:00.000Z');
      expect(json['locationOrMethod'], 'Conference Room B');
      expect(json['subject'], 'Pre-trial strategy discussion');
      expect(json['notes'], 'Bring client contract documents');
    });

    test('omits notes when null', () {
      final request = CreateMeetingRequest(
        caseId: 'c101',
        scheduledAt: DateTime.utc(2026, 9, 25, 14, 30),
        locationOrMethod: 'Zoom Call',
        subject: 'Initial consultation',
      );

      final json = request.toJson();

      expect(json.containsKey('notes'), isFalse);
    });
  });

  group('UpdateMeetingRequest', () {
    test('serializes only provided partial update fields', () {
      final request = UpdateMeetingRequest(
        subject: 'Updated Meeting Subject',
      );

      final json = request.toJson();

      expect(json['subject'], 'Updated Meeting Subject');
      expect(json.containsKey('scheduledAt'), isFalse);
      expect(json.containsKey('locationOrMethod'), isFalse);
      expect(json.containsKey('notes'), isFalse);
    });
  });
}
