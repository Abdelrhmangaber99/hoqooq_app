import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/meeting_requests.dart';
import '../../domain/entities/client_meeting.dart';
import '../../domain/repository/i_meeting_repository.dart';

part 'meeting_form_event.dart';
part 'meeting_form_state.dart';

@injectable
class MeetingFormBloc extends Bloc<MeetingFormEvent, MeetingFormState> {
  MeetingFormBloc(this._repository) : super(const MeetingFormReady()) {
    on<CreateMeetingSubmitted>(_onCreate);
    on<UpdateMeetingSubmitted>(_onUpdate);
  }
  final IMeetingRepository _repository;

  Future<void> _onCreate(
    CreateMeetingSubmitted event,
    Emitter<MeetingFormState> emit,
  ) async {
    if (state is MeetingFormReady && (state as MeetingFormReady).isSubmitting) {
      return;
    }
    emit(const MeetingFormReady(isSubmitting: true));
    final result = await _repository.create(event.request);
    result.fold(
      (failure) => emit(MeetingFormReady(submitError: failure.message)),
      (item) => emit(MeetingFormSuccess(item)),
    );
  }

  Future<void> _onUpdate(
    UpdateMeetingSubmitted event,
    Emitter<MeetingFormState> emit,
  ) async {
    if (state is MeetingFormReady && (state as MeetingFormReady).isSubmitting) {
      return;
    }
    emit(const MeetingFormReady(isSubmitting: true));
    final result = await _repository.update(event.id, event.request);
    result.fold(
      (failure) => emit(MeetingFormReady(submitError: failure.message)),
      (item) => emit(MeetingFormSuccess(item)),
    );
  }
}
