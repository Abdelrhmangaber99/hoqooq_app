import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/client_meeting.dart';
import '../../domain/repository/i_meeting_repository.dart';

part 'case_meetings_event.dart';
part 'case_meetings_state.dart';

@injectable
class CaseMeetingsBloc extends Bloc<CaseMeetingsEvent, CaseMeetingsState> {
  CaseMeetingsBloc(this._repository) : super(CaseMeetingsInitial()) {
    on<FetchCaseMeetingsRequested>(_onFetch);
    on<CompleteMeetingRequested>(_onComplete);
    on<CancelMeetingRequested>(_onCancel);
  }
  final IMeetingRepository _repository;

  Future<void> _onFetch(
    FetchCaseMeetingsRequested event,
    Emitter<CaseMeetingsState> emit,
  ) async {
    emit(CaseMeetingsLoading());
    await _load(event.caseId, emit);
  }

  Future<void> _load(String caseId, Emitter<CaseMeetingsState> emit) async {
    final result = await _repository.getMeetings();
    result.fold(
      (failure) => emit(
        CaseMeetingsError(
          failure.message,
          isForbidden: failure is ForbiddenFailure,
        ),
      ),
      (items) => emit(
        CaseMeetingsLoaded(
          items.where((item) => item.caseId == caseId).toList(),
        ),
      ),
    );
  }

  Future<void> _onComplete(
    CompleteMeetingRequested event,
    Emitter<CaseMeetingsState> emit,
  ) async {
    final current = state;
    if (current is! CaseMeetingsLoaded) return;
    emit(current.copyWith(actionId: event.id));
    final result = await _repository.complete(event.id, event.outcomeNotes);
    await result.fold(
      (failure) async => emit(current.copyWith(actionError: failure.message)),
      (_) async => _load(event.caseId, emit),
    );
  }

  Future<void> _onCancel(
    CancelMeetingRequested event,
    Emitter<CaseMeetingsState> emit,
  ) async {
    final current = state;
    if (current is! CaseMeetingsLoaded) return;
    emit(current.copyWith(actionId: event.id));
    final result = await _repository.cancel(event.id);
    await result.fold(
      (failure) async => emit(current.copyWith(actionError: failure.message)),
      (_) async => _load(event.caseId, emit),
    );
  }
}
