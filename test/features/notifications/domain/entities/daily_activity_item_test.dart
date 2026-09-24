import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/notifications/domain/entities/daily_activity_item.dart';

void main() {
  group('DailyActivityItem.fromJson', () {
    test('parses valid daily activity item JSON for all types', () {
      final jsonHearing = {
        'id': 'd1',
        'type': 'HEARING',
        'caseId': 'c1',
        'dueAt': '2026-09-22T10:00:00.000Z',
        'status': 'SCHEDULED',
      };
      final item = DailyActivityItem.fromJson(jsonHearing);

      expect(item.id, 'd1');
      expect(item.type, DailyActivityType.hearing);
      expect(item.caseId, 'c1');
      expect(item.dueAt, DateTime.utc(2026, 9, 22, 10));
      expect(item.status, 'SCHEDULED');
    });

    test('falls back to unknown for unrecognized type and default status', () {
      final jsonUnknown = {
        'id': 'd2',
        'type': 'SOMETHING_NEW',
        'caseId': 'c2',
        'dueAt': '2026-09-22T12:00:00.000Z',
      };
      final item = DailyActivityItem.fromJson(jsonUnknown);

      expect(item.type, DailyActivityType.unknown);
      expect(item.status, 'UNKNOWN');
    });
  });
}
