import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../cases/domain/entities/court.dart';
import '../../../courts/domain/repository/i_court_repository.dart';
import '../../data/models/update_hearing_request.dart';
import '../../domain/entities/hearing.dart';
import '../../domain/repository/i_hearing_repository.dart';

part 'hearing_form_event.dart';
part 'hearing_form_state.dart';

/// Powers the Edit-Hearing screen (reached from `CaseDetailsPage`'s
/// Hearings section). Update-only — see `IHearingRepository`'s doc
/// comment for why creation is out of scope. "Complete a hearing" (per
/// spec) is just `UpdateHearingSubmitted` with `status: completed` +
/// `outcomeText` set — there's no dedicated endpoint for it.
///
/// Loads Courts once as reference data for the `courtId` picker; a
/// failure degrades to an empty list rather than failing the whole form
/// (optional field, same precedent as `CaseFormBloc`).
@injectable
class HearingFormBloc extends Bloc<HearingFormEvent, HearingFormState> {
  final IHearingRepository _hearingRepository;
  final ICourtRepository _courtRepository;

  HearingFormBloc(this._hearingRepository, this._courtRepository)
    : super(HearingFormInitial()) {
    on<LoadHearingFormReferenceDataRequested>(_onLoad);
    on<UpdateHearingSubmitted>(_onSubmit);
  }

  Future<void> _onLoad(
    LoadHearingFormReferenceDataRequested event,
    Emitter<HearingFormState> emit,
  ) async {
    emit(HearingFormLoading());
    final courtsResult = await _courtRepository.getCourts();
    final courts = courtsResult.fold((_) => const <Court>[], (c) => c);
    emit(HearingFormReady(courts: courts));
  }

  Future<void> _onSubmit(
    UpdateHearingSubmitted event,
    Emitter<HearingFormState> emit,
  ) async {
    final current = state;
    if (current is! HearingFormReady) return;

    emit(current.copyWith(isSubmitting: true, submitError: null));
    final result = await _hearingRepository.updateHearing(
      event.id,
      event.request,
    );
    result.fold(
      (failure) => emit(
        current.copyWith(isSubmitting: false, submitError: failure.message),
      ),
      (updatedHearing) => emit(HearingFormSuccess(updatedHearing)),
    );
  }
}
