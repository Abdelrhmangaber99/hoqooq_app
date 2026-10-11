part of 'calendar_bloc.dart';

abstract class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object?> get props => [];
}

class CalendarInitial extends CalendarState {}

class CalendarLoading extends CalendarState {}

class CalendarLoaded extends CalendarState {
  final List<TimelineItem> items;
  final DateTime selectedDate;
  final CalendarViewMode viewMode;

  /// `GET /calendar/timeline` HEARING items carry only `{id, caseId,
  /// startsAt, status}` — no court, no case number. This resolves each
  /// hearing id to the full [Hearing] from `GET /hearings` (which does join
  /// `court`/`case`), so the day list can show the court name and time
  /// instead of a bare id.
  final Map<String, Hearing> hearingsById;

  const CalendarLoaded(
    this.items,
    this.selectedDate, {
    this.viewMode = CalendarViewMode.month,
    this.hearingsById = const {},
  });

  @override
  List<Object?> get props => [items, selectedDate, viewMode, hearingsById];
}

class CalendarError extends CalendarState {
  final String message;
  final bool isForbidden;
  const CalendarError(this.message, {this.isForbidden = false});

  @override
  List<Object?> get props => [message, isForbidden];
}
