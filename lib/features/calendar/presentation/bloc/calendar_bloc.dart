import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../di/injection.dart';
import '../../../hearings/domain/entities/hearing.dart';
import '../../../hearings/domain/repository/i_hearing_repository.dart';
import '../../domain/entities/timeline_item.dart';
import '../../domain/repository/i_calendar_repository.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

/// Real data via `GET /calendar/timeline` — replaces the mock
/// `Appointment`/`MockAppointmentRepository`. Fetches the whole month
/// containing `_selectedDate` (rather than just one day) so the month-grid
/// view can mark real event days, not the previous hardcoded
/// `[7, 14, 16, 22, 28]` list.
@injectable
class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final ICalendarRepository _calendarRepository;
  DateTime _selectedDate = DateTime.now();
  CalendarViewMode _viewMode = CalendarViewMode.month;
  List<TimelineItem> _items = [];
  Map<String, Hearing> _hearingsById = const {};

  CalendarBloc(this._calendarRepository) : super(CalendarInitial()) {
    on<FetchTimelineRequested>(_onFetch);
    on<SelectDateRequested>((event, emit) {
      final monthChanged =
          event.date.year != _selectedDate.year ||
          event.date.month != _selectedDate.month;
      _selectedDate = event.date;
      if (monthChanged) {
        add(FetchTimelineRequested());
      } else {
        _emitLoaded(emit);
      }
    });
    on<ChangeViewModeRequested>((event, emit) {
      _viewMode = event.mode;
      _emitLoaded(emit);
    });
    on<ChangeYearRequested>((event, emit) {
      _selectedDate = DateTime(
        event.year,
        _selectedDate.month,
        _selectedDate.day,
      );
      add(FetchTimelineRequested());
    });
    on<ChangeMonthRequested>((event, emit) {
      // Clamp the day to the target month's length before constructing the
      // date, so jumping from Jan 31 to February can't silently roll into
      // March (DateTime normalizes out-of-range days).
      final lastDay = DateTime(event.year, event.month + 1, 0).day;
      final day = _selectedDate.day > lastDay ? lastDay : _selectedDate.day;
      _selectedDate = DateTime(event.year, event.month, day);
      add(FetchTimelineRequested());
    });
  }

  Future<void> _onFetch(
    FetchTimelineRequested event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    final monthStart = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final monthEnd = DateTime(
      _selectedDate.year,
      _selectedDate.month + 1,
      1,
    ).subtract(const Duration(microseconds: 1));
    final result = await _calendarRepository.getTimeline(
      startDate: monthStart,
      endDate: monthEnd,
    );
    await result.fold(
      (failure) async {
        emit(
          CalendarError(
            failure.message,
            isForbidden: failure is ForbiddenFailure,
          ),
        );
      },
      (items) async {
        _items = items;
        await _loadHearings();
        _emitLoaded(emit);
      },
    );
  }

  /// Timeline HEARING items are id-only ({id, caseId, startsAt, status}), so
  /// there is no court or case number to show. `GET /hearings` joins both
  /// relations; index the full hearings by id for the day list to resolve.
  /// Degrades to an empty map on failure, and is skipped entirely when the
  /// repository isn't registered (unit tests building this bloc in isolation).
  Future<void> _loadHearings() async {
    if (!getIt.isRegistered<IHearingRepository>()) {
      _hearingsById = const {};
      return;
    }
    try {
      final result = await getIt<IHearingRepository>().getHearings();
      _hearingsById = result.fold(
        (_) => const {},
        (hearings) => {for (final hearing in hearings) hearing.id: hearing},
      );
    } catch (_) {
      _hearingsById = const {};
    }
  }

  void _emitLoaded(Emitter<CalendarState> emit) {
    emit(
      CalendarLoaded(
        _items,
        _selectedDate,
        viewMode: _viewMode,
        hearingsById: _hearingsById,
      ),
    );
  }
}
