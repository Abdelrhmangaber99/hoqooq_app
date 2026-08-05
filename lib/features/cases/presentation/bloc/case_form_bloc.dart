import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../clients/domain/entities/client.dart';
import '../../../clients/domain/repository/i_client_repository.dart';
import '../../../courts/domain/repository/i_court_repository.dart';
import '../../../lookups/domain/entities/lookup.dart';
import '../../../lookups/domain/entities/lookup_kind.dart';
import '../../../lookups/domain/repository/i_lookup_repository.dart';
import '../../../users/domain/repository/i_user_repository.dart';
import '../../data/models/create_case_request.dart';
import '../../data/models/update_case_request.dart';
import '../../domain/entities/court.dart';
import '../../domain/entities/legal_case.dart';
import '../../domain/repository/i_case_repository.dart';

part 'case_form_event.dart';
part 'case_form_state.dart';

/// Powers both the Create-Case and Edit-Case screens. Loads Courts/Users/
/// Clients/case-type Lookups once as reference data; a failure on any one
/// degrades to an empty list rather than failing the whole form (same
/// precedent as M2's `ClientDetailsBloc`) — all four are either optional
/// on write or, for `clients`/`caseTypes`, required only in create mode
/// where the picker itself makes an empty list immediately visible as a
/// problem, rather than silently corrupting a submit.
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
  final IUserRepository _userRepository;
  final IClientRepository _clientRepository;
  final ILookupRepository _lookupRepository;

  CaseFormBloc(
    this._caseRepository,
    this._courtRepository,
    this._userRepository,
    this._clientRepository,
    this._lookupRepository,
  ) : super(CaseFormInitial()) {
    on<LoadCaseFormReferenceDataRequested>(_onLoad);
    on<CreateCaseSubmitted>(_onCreate);
    on<UpdateCaseSubmitted>(_onUpdate);
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
    final courtsFuture = _courtRepository.getCourts();
    final usersFuture = _userRepository.getUsers();
    final clientsFuture = _clientRepository.getClients();
    final caseTypesFuture = _lookupRepository.getLookups(
      kind: LookupKind.caseType,
    );
    final courtsResult = await courtsFuture;
    final usersResult = await usersFuture;
    final clientsResult = await clientsFuture;
    final caseTypesResult = await caseTypesFuture;
    final courts = courtsResult.fold((_) => const <Court>[], (c) => c);
    final users = usersResult.fold((_) => const <User>[], (u) => u);
    final clients = clientsResult.fold((_) => const <Client>[], (c) => c);
    final caseTypes = caseTypesResult.fold((_) => const <Lookup>[], (l) => l);
    emit(
      CaseFormReady(
        courts: courts,
        users: users,
        clients: clients,
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
