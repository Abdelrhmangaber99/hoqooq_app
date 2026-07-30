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
        userId: 'u1',
        title: 'Team sync',
        startsAt: DateTime.utc(2026, 2, 1, 9),
        isAllDay: false,
      );
      final result = await repository.createEvent(request);

      final captured = verify(
        () => dio.post('/calendar', data: captureAny(named: 'data')),
      ).captured;
      final body = captured.single as Map<String, dynamic>;
      expect(body['userId'], 'u1');
      expect(body['title'], 'Team sync');
      expect(body['eventType'], 'CUSTOM');
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
        userId: 'u1',
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
