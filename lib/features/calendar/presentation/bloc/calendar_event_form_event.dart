part of 'calendar_event_form_bloc.dart';

abstract class CalendarEventFormEvent extends Equatable {
  const CalendarEventFormEvent();

  @override
  List<Object?> get props => [];
}

class CreateEventSubmitted extends CalendarEventFormEvent {
  final CreateEventRequest request;
  const CreateEventSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}
