import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/calendar/domain/entities/calendar_event_type.dart';
import 'package:hqooq/features/calendar/domain/entities/timeline_item.dart';
import 'package:hqooq/features/calendar/domain/repository/i_calendar_repository.dart';
import 'package:hqooq/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockCalendarRepository extends Mock implements ICalendarRepository {}

void main() {
  late MockCalendarRepository repository;

  final item = TimelineItem.event(
    id: 'e1',
    title: 'Team sync',
    date: DateTime(2026, 2, 1),
    eventType: CalendarEventType.custom,
  );

  setUp(() {
    repository = MockCalendarRepository();
    registerFallbackValue(DateTime(2026, 1, 1));
  });

  blocTest<CalendarBloc, CalendarState>(
    'emits [Loading, Loaded] on FetchTimelineRequested',
    build: () {
      when(
        () => repository.getTimeline(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right([item]));
      return CalendarBloc(repository);
    },
    act: (bloc) => bloc.add(FetchTimelineRequested()),
    expect: () => [isA<CalendarLoading>(), isA<CalendarLoaded>()],
  );

  blocTest<CalendarBloc, CalendarState>(
    'emits [Loading, Error] when the fetch fails',
    build: () {
      when(
        () => repository.getTimeline(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return CalendarBloc(repository);
    },
    act: (bloc) => bloc.add(FetchTimelineRequested()),
    expect: () => [isA<CalendarLoading>(), isA<CalendarError>()],
  );

  blocTest<CalendarBloc, CalendarState>(
    'selecting a date within the same month does not re-fetch',
    build: () {
      when(
        () => repository.getTimeline(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right([item]));
      return CalendarBloc(repository);
    },
    act: (bloc) async {
      bloc.add(FetchTimelineRequested());
      await Future.delayed(Duration.zero);
      bloc.add(SelectDateRequested(DateTime.now()));
    },
    verify: (_) {
      verify(
        () => repository.getTimeline(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).called(1);
    },
  );

  blocTest<CalendarBloc, CalendarState>(
    'changing the view mode re-emits Loaded without re-fetching',
    build: () {
      when(
        () => repository.getTimeline(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right([item]));
      return CalendarBloc(repository);
    },
    act: (bloc) async {
      bloc.add(FetchTimelineRequested());
      await Future.delayed(Duration.zero);
      bloc.add(const ChangeViewModeRequested(CalendarViewMode.week));
    },
    expect: () => [
      isA<CalendarLoading>(),
      isA<CalendarLoaded>(),
      isA<CalendarLoaded>().having(
        (s) => s.viewMode,
        'viewMode',
        CalendarViewMode.week,
      ),
    ],
    verify: (_) {
      verify(
        () => repository.getTimeline(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).called(1);
    },
  );
}
