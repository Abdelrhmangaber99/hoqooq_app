import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/calendar/data/models/create_event_request.dart';
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
    test('GETs /calendar/timeline and parses a CUSTOM item', () async {
      when(
        () => dio.get(
          '/calendar/timeline',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => okResponse('/calendar/timeline', [
          {
            'id': 'e1',
            'type': 'CUSTOM',
            'title': 'Team sync',
            'startsAt': '2026-02-01T09:00:00.000Z',
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

    test('parses a Case-bound HEARING item', () async {
      when(
        () => dio.get(
          '/calendar/timeline',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => okResponse('/calendar/timeline', [
          {
            'id': 'h1',
            'type': 'HEARING',
            'caseId': 'c1',
            'startsAt': '2026-02-01T09:00:00.000Z',
            'status': 'SCHEDULED',
          },
        ]),
      );

      final result = await repository.getTimeline();

      result.fold((_) => fail('expected Right'), (items) {
        final item = items.first as TimelineHearingItem;
        expect(item.status, HearingStatus.scheduled);
        expect(item.caseId, 'c1');
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
              'type': 'TASK',
              'title': 'File motion',
              'startsAt': '2026-02-01T00:00:00.000Z',
              'caseId': 'c1',
              'status': 'SOMETHING_NEW',
              'priority': 'HIGH',
            },
          ]),
        );

        final result = await repository.getTimeline();

        result.fold((_) => fail('expected Right'), (items) {
          final item = items.first as TimelineTaskItem;
          expect(item.status, TaskStatus.unknown);
          expect(item.priority, TaskPriority.high);
          expect(item.caseSummary, isNull);
          expect(item.caseId, 'c1');
        });
      },
    );

    test('parses Service and Meeting activity sources', () async {
      when(
        () => dio.get(
          '/calendar/timeline',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => okResponse('/calendar/timeline', [
          {
            'id': 's1',
            'type': 'SERVICE',
            'caseId': 'c1',
            'startsAt': '2026-02-01T08:00:00.000Z',
            'status': 'SCHEDULED',
          },
          {
            'id': 'm1',
            'type': 'MEETING',
            'caseId': 'c1',
            'title': 'Client preparation',
            'startsAt': '2026-02-01T10:00:00.000Z',
            'status': 'RESCHEDULED',
          },
        ]),
      );

      final result = await repository.getTimeline();

      result.fold((_) => fail('expected Right'), (items) {
        expect(items.first, isA<TimelineServiceItem>());
        expect(items.last, isA<TimelineMeetingItem>());
      });
    });

    test('passes startDate/endDate/caseId as query parameters', () async {
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
      );

      verify(
        () => dio.get(
          '/calendar/timeline',
          queryParameters: {
            'startDate': DateTime.utc(2026, 2, 1).toIso8601String(),
            'endDate': DateTime.utc(2026, 2, 28).toIso8601String(),
            'caseId': 'c1',
          },
        ),
      ).called(1);
    });

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

  group('createEvent', () {
    test('POSTs /calendar with the full CreateEventDto-shaped body', () async {
      when(() => dio.post('/calendar', data: any(named: 'data'))).thenAnswer(
        (_) async => okResponse('/calendar', {
          'id': 'e1',
          'tenantId': 't1',
          'userId': 'u1',
          'title': 'Team sync',
          'eventType': 'CUSTOM',
          'startsAt': '2026-02-01T09:00:00.000Z',
          'isAllDay': false,
          'createdAt': '2026-01-01T00:00:00.000Z',
          'updatedAt': '2026-01-01T00:00:00.000Z',
        }),
      );

      final request = CreateEventRequest(
        title: 'Team sync',
        startsAt: DateTime.utc(2026, 2, 1, 9),
        isAllDay: false,
      );
      final result = await repository.createEvent(request);

      final captured = verify(
        () => dio.post('/calendar', data: captureAny(named: 'data')),
      ).captured;
      final body = captured.single as Map<String, dynamic>;
      expect(body.containsKey('userId'), isFalse);
      expect(body['title'], 'Team sync');
      expect(body.containsKey('eventType'), isFalse);
      expect(body['isAllDay'], false);
      result.fold(
        (_) => fail('expected Right'),
        (event) => expect(event.title, 'Team sync'),
      );
    });

    test('maps a 400 to ValidationFailure', () async {
      when(() => dio.post('/calendar', data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/calendar'),
          response: Response(
            requestOptions: RequestOptions(path: '/calendar'),
            statusCode: 400,
            data: {'message': 'startsAt must be a valid ISO date string'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final request = CreateEventRequest(
        title: 'Team sync',
        startsAt: DateTime.utc(2026, 2, 1, 9),
      );
      final result = await repository.createEvent(request);

      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
