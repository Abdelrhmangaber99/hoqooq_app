import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/calendar/data/repository/calendar_repository.dart';
import 'package:hqooq/features/calendar/domain/entities/calendar_event_type.dart';
import 'package:hqooq/features/calendar/domain/entities/timeline_item.dart';
import 'package:hqooq/features/hearings/domain/entities/hearing_status.dart';
import 'package:hqooq/features/tasks/domain/entities/task_priority.dart';
import 'package:hqooq/features/tasks/domain/entities/task_status.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late CalendarRepository repository;

  setUp(() {
    dio = MockDio();
    repository = CalendarRepository(dio);
  });

  Response<T> okResponse<T>(String path, T data) {
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: data,
      statusCode: 200,
    );
  }

  group('getTimeline', () {
    test('GETs /calendar/timeline and parses a CALENDAR_EVENT item', () async {
      when(
        () => dio.get(
          '/calendar/timeline',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => okResponse('/calendar/timeline', [
          {
            'id': 'e1',
            'itemType': 'CALENDAR_EVENT',
            'title': 'Team sync',
            'date': '2026-02-01T09:00:00.000Z',
            'eventType': 'CUSTOM',
            'referenceId': null,
          },
        ]),
      );

      final result = await repository.getTimeline();

      verify(
        () =>
            dio.get('/calendar/timeline', queryParameters: <String, dynamic>{}),
      ).called(1);
      result.fold((_) => fail('expected Right'), (items) {
        expect(items, hasLength(1));
        final item = items.first;
        expect(item, isA<TimelineEventItem>());
        expect((item as TimelineEventItem).eventType, CalendarEventType.custom);
      });
    });

    test('parses a HEARING item with a nested case', () async {
      when(
        () => dio.get(
          '/calendar/timeline',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => okResponse('/calendar/timeline', [
          {
            'id': 'h1',
            'itemType': 'HEARING',
            'title': 'Hearing for Case CASE-2026-00001',
            'date': '2026-02-01T09:00:00.000Z',
            'status': 'SCHEDULED',
            'case': {
              'id': 'c1',
              'tenantId': 't1',
              'caseNumber': 'CASE-2026-00001',
              'status': 'ACTIVE',
              'clientId': 'cl1',
              'caseTypeId': 'ct1',
              'priority': 'HIGH',
              'createdAt': '2026-01-01T00:00:00.000Z',
              'updatedAt': '2026-01-01T00:00:00.000Z',
            },
          },
        ]),
      );

      final result = await repository.getTimeline();

      result.fold((_) => fail('expected Right'), (items) {
        final item = items.first as TimelineHearingItem;
        expect(item.status, HearingStatus.scheduled);
        expect(item.caseSummary?.caseNumber, 'CASE-2026-00001');
      });
    });

    test(
      'parses a TASK item and falls back to unknown for a bad enum',
      () async {
        when(
          () => dio.get(
            '/calendar/timeline',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => okResponse('/calendar/timeline', [
            {
              'id': 't1',
              'itemType': 'TASK',
              'title': 'File motion',
              'date': '2026-02-01T00:00:00.000Z',
              'status': 'SOMETHING_NEW',
              'priority': 'HIGH',
              'case': null,
            },
          ]),
        );

        final result = await repository.getTimeline();

        result.fold((_) => fail('expected Right'), (items) {
          final item = items.first as TimelineTaskItem;
          expect(item.status, TaskStatus.unknown);
          expect(item.priority, TaskPriority.high);
          expect(item.caseSummary, isNull);
        });
      },
    );

    test(
      'passes startDate/endDate/caseId/userId as query parameters',
      () async {
        when(
          () => dio.get(
            '/calendar/timeline',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer((_) async => okResponse('/calendar/timeline', []));

        await repository.getTimeline(
          startDate: DateTime.utc(2026, 2, 1),
          endDate: DateTime.utc(2026, 2, 28),
          caseId: 'c1',
          userId: 'u1',
        );

        verify(
          () => dio.get(
            '/calendar/timeline',
            queryParameters: {
              'startDate': DateTime.utc(2026, 2, 1).toIso8601String(),
              'endDate': DateTime.utc(2026, 2, 28).toIso8601String(),
              'caseId': 'c1',
              'userId': 'u1',
            },
          ),
        ).called(1);
      },
    );

    test('maps a connection error to NetworkFailure', () async {
      when(
        () => dio.get(
          '/calendar/timeline',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/calendar/timeline'),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await repository.getTimeline();

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
