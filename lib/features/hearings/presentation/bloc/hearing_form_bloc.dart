import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../cases/domain/entities/court.dart';
import '../../../courts/domain/entities/court_circuit.dart';
import '../../../courts/domain/repository/i_court_repository.dart';
import '../../../lookups/domain/entities/lookup.dart';
import '../../../lookups/domain/entities/lookup_kind.dart';
import '../../../lookups/domain/repository/i_lookup_repository.dart';
import '../../data/models/create_hearing_request.dart';
import '../../data/models/complete_hearing_request.dart';
import '../../data/models/update_hearing_request.dart';
import '../../domain/entities/hearing.dart';
import '../../domain/repository/i_hearing_repository.dart';

part 'hearing_form_event.dart';
part 'hearing_form_state.dart';

/// Powers the Create/Edit/Complete Hearing flow reached from Case Details.
/// Completion uses `PATCH /hearings/{id}/complete`.
///
/// Loads Governorate-scoped Courts + hearing-type Lookups as reference data;
/// Circuits are loaded for the selected Court. A failure
/// on either degrades to an empty list rather than failing the whole form.
/// Hearing creation was blocked until 2026-08-05 — `hearingTypeId` had no
/// real, listable source before `GET /lookups?kind=HEARING_TYPE` existed
/// (API_CONTRACT.md finding K).
@injectable
class HearingFormBloc extends Bloc<HearingFormEvent, HearingFormState> {
  final IHearingRepository _hearingRepository;
  final ICourtRepository _courtRepository;
  final ILookupRepository _lookupRepository;

  HearingFormBloc(
    this._hearingRepository,
    this._courtRepository,
    this._lookupRepository,
  ) : super(HearingFormInitial()) {
    on<LoadHearingFormReferenceDataRequested>(_onLoad);
    on<LoadHearingCircuitsRequested>(_onLoadCircuits);
    on<CreateHearingSubmitted>(_onCreate);
    on<UpdateHearingSubmitted>(_onSubmit);
    on<CompleteHearingSubmitted>(_onComplete);
  }

  Future<void> _onLoad(
    LoadHearingFormReferenceDataRequested event,
    Emitter<HearingFormState> emit,
  ) async {
    emit(HearingFormLoading());
    // Started concurrently, awaited afterward — 1 round-trip instead of 2
    // sequential ones. See CaseFormBloc._onLoad for the same pattern.
    final courtsFuture = _courtRepository.getCourts(event.governorateId);
    final hearingTypesFuture = _lookupRepository.getLookups(
      kind: LookupKind.hearingType,
    );
    final circuitsFuture = event.initialCourtId == null
        ? null
        : _courtRepository.getCircuits(event.initialCourtId!);
    final courtsResult = await courtsFuture;
    final hearingTypesResult = await hearingTypesFuture;
    final courts = courtsResult.fold((_) => const <Court>[], (c) => c);
    final courtLoadError = courtsResult.fold(
      (failure) => failure.message,
      (_) => null,
    );
    final hearingTypes = hearingTypesResult.fold(
      (_) => const <Lookup>[],
      (l) => l,
    );
    final hearingTypeLoadError = hearingTypesResult.fold(
      (failure) => failure.message,
      (_) => null,
    );
    final circuitsResult = await circuitsFuture;
    final circuits = circuitsResult?.fold(
          (_) => const <CourtCircuit>[],
          (items) => items,
        ) ??
        const <CourtCircuit>[];
    emit(
      HearingFormReady(
        courts: courts,
        hearingTypes: hearingTypes,
        circuits: circuits,
        courtLoadError: courtLoadError,
        hearingTypeLoadError: hearingTypeLoadError,
      ),
    );
  }

  Future<void> _onLoadCircuits(
    LoadHearingCircuitsRequested event,
    Emitter<HearingFormState> emit,
  ) async {
    final current = state;
    if (current is! HearingFormReady) return;
    final result = await _courtRepository.getCircuits(event.courtId);
    emit(current.copyWith(circuits: result.fold((_) => [], (items) => items)));
  }

  Future<void> _onCreate(
    CreateHearingSubmitted event,
    Emitter<HearingFormState> emit,
  ) async {
    final current = state;
    if (current is! HearingFormReady) return;
    if (current.isSubmitting) return;

    emit(current.copyWith(isSubmitting: true, submitError: null));
    final result = await _hearingRepository.createHearing(event.request);
    result.fold(
      (failure) => emit(
        current.copyWith(isSubmitting: false, submitError: failure.message),
      ),
      (createdHearing) => emit(HearingFormSuccess(createdHearing)),
    );
  }

  Future<void> _onSubmit(
    UpdateHearingSubmitted event,
    Emitter<HearingFormState> emit,
  ) async {
    final current = state;
    if (current is! HearingFormReady) return;
    if (current.isSubmitting) return;

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

  Future<void> _onComplete(
    CompleteHearingSubmitted event,
    Emitter<HearingFormState> emit,
  ) async {
    final current = state;
    if (current is! HearingFormReady) return;
    if (current.isSubmitting) return;

    emit(current.copyWith(isSubmitting: true, submitError: null));
    final result = await _hearingRepository.completeHearing(
      event.id,
      event.request,
    );
    result.fold(
      (failure) => emit(
        current.copyWith(isSubmitting: false, submitError: failure.message),
      ),
      (hearing) => emit(HearingFormSuccess(hearing)),
    );
  }
}
