part of 'calendar_bloc.dart';

enum CalendarViewMode { month, week, day }

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

class FetchTimelineRequested extends CalendarEvent {}

class SelectDateRequested extends CalendarEvent {
  final DateTime date;
  const SelectDateRequested(this.date);

  @override
  List<Object?> get props => [date];
}

class ChangeViewModeRequested extends CalendarEvent {
  final CalendarViewMode mode;
  const ChangeViewModeRequested(this.mode);

  @override
  List<Object?> get props => [mode];
}

class ChangeYearRequested extends CalendarEvent {
  final int year;
  const ChangeYearRequested(this.year);

  @override
  List<Object?> get props => [year];
}

/// Jump to an arbitrary year+month (the header's month picker). Keeps the
/// selected day where possible, clamped to the target month's last day so
/// e.g. Jan 31 → Feb lands on Feb 28/29 instead of rolling into March.
class ChangeMonthRequested extends CalendarEvent {
  final int year;
  final int month;
  const ChangeMonthRequested(this.year, this.month);

  @override
  List<Object?> get props => [year, month];
}
