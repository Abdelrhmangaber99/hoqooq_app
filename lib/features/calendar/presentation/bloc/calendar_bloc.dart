import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
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
  }

  Future<void> _onFetch(
    FetchTimelineRequested event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    final monthStart = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final monthEnd = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final result = await _calendarRepository.getTimeline(
      startDate: monthStart,
      endDate: monthEnd,
    );
    result.fold((failure) => emit(CalendarError(failure.message)), (items) {
      _items = items;
      _emitLoaded(emit);
    });
  }

  void _emitLoaded(Emitter<CalendarState> emit) {
    emit(CalendarLoaded(_items, _selectedDate, viewMode: _viewMode));
  }
}
