import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../courts/domain/repository/i_court_repository.dart';
import '../../../users/domain/repository/i_user_repository.dart';
import '../../data/models/update_case_request.dart';
import '../../domain/entities/court.dart';
import '../../domain/entities/legal_case.dart';
import '../../domain/repository/i_case_repository.dart';

part 'case_form_event.dart';
part 'case_form_state.dart';

/// Powers the Edit-Case screen. Update-only — see `ICaseRepository`'s doc
/// comment for why creation is out of scope. Loads Courts/Users once as
/// reference data for the `defaultCourtId`/`primaryLawyerId` pickers; a
/// failure on either degrades to an empty list rather than failing the
/// whole form (same precedent as M2's `ClientDetailsBloc`), since both
/// fields are optional on update.
///
/// Does not refetch the case itself on success — explicit refetch is the
/// caller's job (the screen pops with `true` and `CaseDetailsPage`
/// reloads), per the project's standing write-completion convention.
@injectable
class CaseFormBloc extends Bloc<CaseFormEvent, CaseFormState> {
  final ICaseRepository _caseRepository;
  final ICourtRepository _courtRepository;
  final IUserRepository _userRepository;

  CaseFormBloc(
    this._caseRepository,
    this._courtRepository,
    this._userRepository,
  ) : super(CaseFormInitial()) {
    on<LoadCaseFormReferenceDataRequested>(_onLoad);
    on<UpdateCaseSubmitted>(_onSubmit);
  }

  Future<void> _onLoad(
    LoadCaseFormReferenceDataRequested event,
    Emitter<CaseFormState> emit,
  ) async {
    emit(CaseFormLoading());
    final courtsResult = await _courtRepository.getCourts();
    final usersResult = await _userRepository.getUsers();
    final courts = courtsResult.fold((_) => const <Court>[], (c) => c);
    final users = usersResult.fold((_) => const <User>[], (u) => u);
    emit(CaseFormReady(courts: courts, users: users));
  }

  Future<void> _onSubmit(
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
