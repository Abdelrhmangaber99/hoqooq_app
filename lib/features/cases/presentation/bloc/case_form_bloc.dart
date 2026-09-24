import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../courts/domain/repository/i_court_repository.dart';
import '../../../courts/domain/entities/case_type_reference.dart';
import '../../../courts/domain/entities/governorate.dart';
import '../../../courts/domain/entities/court_circuit.dart';
import '../../../lookups/domain/repository/i_lookup_repository.dart';
import '../../../users/domain/repository/i_user_repository.dart';
import '../../data/models/create_case_request.dart';
import '../../data/models/update_case_request.dart';
import '../../domain/entities/court.dart';
import '../../domain/entities/legal_case.dart';
import '../../domain/repository/i_case_repository.dart';

part 'case_form_event.dart';
part 'case_form_state.dart';

/// Powers both the Create-Case and Edit-Case screens. Loads global
/// Governorates and Case Types from the backend. Court choices use the same
/// dependent judicial-reference endpoint as the web frontend after a
/// Governorate is selected.
///
/// Case creation was blocked until 2026-08-05 — `caseTypeId` had no real,
/// listable source before `GET /lookups?kind=CASE_TYPE` existed
/// (API_CONTRACT.md finding K).
///
/// Does not refetch the case itself on success — explicit refetch is the
/// caller's job (the screen pops with `true` and the calling screen
/// reloads), per the project's standing write-completion convention.
@injectable
class CaseFormBloc extends Bloc<CaseFormEvent, CaseFormState> {
  final ICaseRepository _caseRepository;
  final ICourtRepository _courtRepository;

  CaseFormBloc(
    this._caseRepository,
    this._courtRepository,
    IUserRepository _,
    ILookupRepository ___,
  ) : super(CaseFormInitial()) {
    on<LoadCaseFormReferenceDataRequested>(_onLoad);
    on<LoadCaseCourtsRequested>(_onLoadCourts);
    on<LoadCaseCircuitsRequested>(_onLoadCircuits);
    on<CreateCaseSubmitted>(_onCreate);
    on<UpdateCaseSubmitted>(_onUpdate);
  }

  Future<void> _onLoadCircuits(
    LoadCaseCircuitsRequested event,
    Emitter<CaseFormState> emit,
  ) async {
    final current = state;
    if (current is! CaseFormReady) return;
    final result = await _courtRepository.getCircuits(event.courtId);
    emit(
      current.copyWith(
        circuits: result.fold((_) => const [], (items) => items),
      ),
    );
  }

  Future<void> _onLoadCourts(
    LoadCaseCourtsRequested event,
    Emitter<CaseFormState> emit,
  ) async {
    final current = state;
    if (current is! CaseFormReady) return;

    emit(
      current.copyWith(
        courts: const <Court>[],
        circuits: const <CourtCircuit>[],
        isLoadingCourts: true,
        courtLoadError: null,
      ),
    );
    final result = await _courtRepository.getCourts(event.governorateId);
    result.fold(
      (failure) => emit(
        current.copyWith(
          courts: const <Court>[],
          circuits: const <CourtCircuit>[],
          isLoadingCourts: false,
          courtLoadError: failure.message,
        ),
      ),
      (courts) => emit(
        current.copyWith(
          courts: courts,
          circuits: const <CourtCircuit>[],
          isLoadingCourts: false,
          courtLoadError: null,
        ),
      ),
    );
  }

  Future<void> _onLoad(
    LoadCaseFormReferenceDataRequested event,
    Emitter<CaseFormState> emit,
  ) async {
    emit(CaseFormLoading());
    // Started concurrently (each call below returns its Future immediately
    // and begins its own request), then awaited afterward — 1 round-trip
    // of latency instead of 4 sequential ones. Kept as separate typed
    // futures rather than `Future.wait` since the four results have
    // different generic types.
    final governoratesFuture = _courtRepository.getGovernorates();
    final caseTypesFuture = _courtRepository.getCaseTypes();
    final governoratesResult = await governoratesFuture;
    final caseTypesResult = await caseTypesFuture;
    final governorates = governoratesResult.fold(
      (_) => const <Governorate>[],
      (items) => items,
    );
    final caseTypes = caseTypesResult.fold(
      (_) => const <CaseTypeReference>[],
      (items) => items,
    );
    emit(
      CaseFormReady(
        governorates: governorates,
        courts: const <Court>[],
        circuits: const <CourtCircuit>[],
        caseTypes: caseTypes,
      ),
    );
  }

  Future<void> _onCreate(
    CreateCaseSubmitted event,
    Emitter<CaseFormState> emit,
  ) async {
    final current = state;
    if (current is! CaseFormReady) return;
    if (current.isSubmitting) return;

    emit(current.copyWith(isSubmitting: true, submitError: null));
    final result = await _caseRepository.createCase(event.request);
    result.fold(
      (failure) => emit(
        current.copyWith(isSubmitting: false, submitError: failure.message),
      ),
      (createdCase) => emit(CaseFormSuccess(createdCase)),
    );
  }

  Future<void> _onUpdate(
    UpdateCaseSubmitted event,
    Emitter<CaseFormState> emit,
  ) async {
    final current = state;
    if (current is! CaseFormReady) return;
    if (current.isSubmitting) return;

    emit(current.copyWith(isSubmitting: true, submitError: null));
    final result = await _caseRepository.updateCase(event.id, event.request);
    result.fold(
      (failure) => emit(
        current.copyWith(isSubmitting: false, submitError: failure.message),
      ),
      (updatedCase) => emit(CaseFormSuccess(updatedCase)),
    );
  }
}
