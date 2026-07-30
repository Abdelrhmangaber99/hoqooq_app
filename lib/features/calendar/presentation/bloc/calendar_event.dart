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
