import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/create_event_request.dart';
import '../../domain/entities/calendar_event_entity.dart';
import '../../domain/repository/i_calendar_repository.dart';

part 'calendar_event_form_event.dart';
part 'calendar_event_form_state.dart';

/// Powers the New Custom Event screen — a dedicated write-only bloc,
/// sibling to `CalendarBloc` (read), same precedent as `ClientFormBloc`/
/// `TaskFormBloc`. Create-only: no update/delete, deferred across every
/// module this milestone (see PLAN.md's M4 scope table).
///
/// Does not refetch anything itself on success — explicit refetch is the
/// caller's job, per the project's standing write-completion convention.
@injectable
class CalendarEventFormBloc
    extends Bloc<CalendarEventFormEvent, CalendarEventFormState> {
  final ICalendarRepository _calendarRepository;

  CalendarEventFormBloc(this._calendarRepository)
    : super(CalendarEventFormInitial()) {
    on<CreateEventSubmitted>(_onCreate);
  }

  Future<void> _onCreate(
    CreateEventSubmitted event,
    Emitter<CalendarEventFormState> emit,
  ) async {
    emit(CalendarEventFormSubmitting());
    final result = await _calendarRepository.createEvent(event.request);
    result.fold(
      (failure) => emit(CalendarEventFormFailure(failure.message)),
      (calendarEvent) => emit(CalendarEventFormSuccess(calendarEvent)),
    );
  }
}
