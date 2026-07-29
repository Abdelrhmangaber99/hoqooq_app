import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/usecases/get_appointments_use_case.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

@injectable
class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final GetAppointmentsUseCase _getAppointmentsUseCase;
  DateTime _selectedDate = DateTime(2026, 7, 16);
  CalendarViewMode _viewMode = CalendarViewMode.month;

  CalendarBloc(this._getAppointmentsUseCase) : super(CalendarInitial()) {
    on<FetchAppointmentsRequested>((event, emit) async {
      emit(CalendarLoading());
      if (event.date != null) _selectedDate = event.date!;
      
      final result = await _getAppointmentsUseCase.execute(date: _selectedDate);
      
      result.fold(
        (failure) => emit(CalendarError(failure.message)),
        (appointments) => emit(CalendarLoaded(appointments, _selectedDate, viewMode: _viewMode)),
      );
    });

    on<SelectDateRequested>((event, emit) async {
      _selectedDate = event.date;
      add(FetchAppointmentsRequested(date: _selectedDate));
    });

    on<ChangeViewModeRequested>((event, emit) async {
      _viewMode = event.mode;
      add(FetchAppointmentsRequested(date: _selectedDate));
    });

    on<ChangeYearRequested>((event, emit) async {
      _selectedDate = DateTime(event.year, _selectedDate.month, _selectedDate.day);
      add(FetchAppointmentsRequested(date: _selectedDate));
    });
  }
}
