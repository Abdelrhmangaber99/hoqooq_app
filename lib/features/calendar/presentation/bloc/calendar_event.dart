part of 'calendar_bloc.dart';

enum CalendarViewMode { month, week, day }

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

class FetchAppointmentsRequested extends CalendarEvent {
  final DateTime? date;
  const FetchAppointmentsRequested({this.date});

  @override
  List<Object?> get props => [date];
}

class SelectDateRequested extends CalendarEvent {
  final DateTime date;
  const SelectDateRequested(this.date);

  @override
  List<Object?> get props => [date];
}

class ChangeViewModeRequested extends CalendarViewModeRequested {
  final CalendarViewMode mode;
   ChangeViewModeRequested(this.mode);

  @override
  List<Object?> get props => [mode];
}

class ChangeYearRequested extends CalendarEvent {
  final int year;
  const ChangeYearRequested(this.year);

  @override
  List<Object?> get props => [year];
}

// Keeping compatibility with existing code while transitioning
abstract class CalendarViewModeRequested extends CalendarEvent {}
