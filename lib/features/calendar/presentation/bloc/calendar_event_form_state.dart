part of 'calendar_event_form_bloc.dart';

abstract class CalendarEventFormState extends Equatable {
  const CalendarEventFormState();

  @override
  List<Object?> get props => [];
}

class CalendarEventFormInitial extends CalendarEventFormState {}

class CalendarEventFormSubmitting extends CalendarEventFormState {}

class CalendarEventFormSuccess extends CalendarEventFormState {
  final CalendarEventEntity calendarEvent;
  const CalendarEventFormSuccess(this.calendarEvent);

  @override
  List<Object?> get props => [calendarEvent];
}

class CalendarEventFormFailure extends CalendarEventFormState {
  final String message;
  const CalendarEventFormFailure(this.message);

  @override
  List<Object?> get props => [message];
}
