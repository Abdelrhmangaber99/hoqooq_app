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

  const CalendarLoaded(
    this.items,
    this.selectedDate, {
    this.viewMode = CalendarViewMode.month,
  });

  @override
  List<Object?> get props => [items, selectedDate, viewMode];
}

class CalendarError extends CalendarState {
  final String message;
  const CalendarError(this.message);

  @override
  List<Object?> get props => [message];
}
