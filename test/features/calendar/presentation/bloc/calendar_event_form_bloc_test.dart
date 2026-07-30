import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/calendar/data/models/create_event_request.dart';
import 'package:hqooq/features/calendar/domain/entities/calendar_event_entity.dart';
import 'package:hqooq/features/calendar/domain/entities/calendar_event_type.dart';
import 'package:hqooq/features/calendar/domain/repository/i_calendar_repository.dart';
import 'package:hqooq/features/calendar/presentation/bloc/calendar_event_form_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockCalendarRepository extends Mock implements ICalendarRepository {}

void main() {
  late MockCalendarRepository calendarRepository;

  final calendarEvent = CalendarEventEntity(
    id: 'e1',
    tenantId: 't1',
    userId: 'u1',
    title: 'Team sync',
    eventType: CalendarEventType.custom,
    startsAt: DateTime.utc(2026, 2, 1, 9),
    isAllDay: false,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(
      CreateEventRequest(userId: '', title: '', startsAt: DateTime.utc(2026)),
    );
  });

  setUp(() {
    calendarRepository = MockCalendarRepository();
  });

  blocTest<CalendarEventFormBloc, CalendarEventFormState>(
    'emits [Submitting, Success] on a successful create',
    build: () {
      when(
        () => calendarRepository.createEvent(any()),
      ).thenAnswer((_) async => Right(calendarEvent));
      return CalendarEventFormBloc(calendarRepository);
    },
    act: (bloc) => bloc.add(
      CreateEventSubmitted(
        CreateEventRequest(
          userId: 'u1',
          title: 'Team sync',
          startsAt: DateTime.utc(2026, 2, 1, 9),
        ),
      ),
    ),
    expect: () => [
      CalendarEventFormSubmitting(),
      CalendarEventFormSuccess(calendarEvent),
    ],
  );

  blocTest<CalendarEventFormBloc, CalendarEventFormState>(
    'emits [Submitting, Failure] when the create fails',
    build: () {
      when(
        () => calendarRepository.createEvent(any()),
      ).thenAnswer((_) async => const Left(ValidationFailure('bad request')));
      return CalendarEventFormBloc(calendarRepository);
    },
    act: (bloc) => bloc.add(
      CreateEventSubmitted(
        CreateEventRequest(
          userId: 'u1',
          title: '',
          startsAt: DateTime.utc(2026, 2, 1, 9),
        ),
      ),
    ),
    expect: () => [
      CalendarEventFormSubmitting(),
      const CalendarEventFormFailure('bad request'),
    ],
  );
}
