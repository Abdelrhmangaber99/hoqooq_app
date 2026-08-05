import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../users/domain/repository/i_user_repository.dart';
import '../../data/models/assign_case_request.dart';
import '../../domain/entities/case_team_member.dart';
import '../../domain/repository/i_case_repository.dart';

part 'case_team_assignment_event.dart';
part 'case_team_assignment_state.dart';

/// Powers the "Add team member" bottom sheet on `CaseDetailsPage`, backed
/// by `POST /cases/:id/assignments` — restored 2026-08-05 after being
/// removed pre-M2 (API_CONTRACT.md finding P). Loads Users once as
/// reference data for the assignee picker; a failure degrades to an
/// empty list rather than failing the whole sheet.
///
/// Does not refetch the case itself on success — the sheet closes and the
/// caller (`CaseDetailsPage`) refetches, same explicit-refetch convention
/// as every other write path.
@injectable
class CaseTeamAssignmentBloc
    extends Bloc<CaseTeamAssignmentEvent, CaseTeamAssignmentState> {
  final ICaseRepository _caseRepository;
  final IUserRepository _userRepository;

  CaseTeamAssignmentBloc(this._caseRepository, this._userRepository)
    : super(CaseTeamAssignmentInitial()) {
    on<LoadCaseTeamAssignmentReferenceDataRequested>(_onLoad);
    on<CaseTeamAssignmentSubmitted>(_onSubmit);
  }

  Future<void> _onLoad(
    LoadCaseTeamAssignmentReferenceDataRequested event,
    Emitter<CaseTeamAssignmentState> emit,
  ) async {
    emit(CaseTeamAssignmentLoading());
    final usersResult = await _userRepository.getUsers();
    final users = usersResult.fold((_) => const <User>[], (u) => u);
    emit(CaseTeamAssignmentReady(users: users));
  }

  Future<void> _onSubmit(
    CaseTeamAssignmentSubmitted event,
    Emitter<CaseTeamAssignmentState> emit,
  ) async {
    final current = state;
    if (current is! CaseTeamAssignmentReady) return;

    emit(current.copyWith(isSubmitting: true, submitError: null));
    final result = await _caseRepository.assignTeamMember(
      event.caseId,
      event.request,
    );
    result.fold(
      (failure) => emit(
        current.copyWith(isSubmitting: false, submitError: failure.message),
      ),
      (member) => emit(CaseTeamAssignmentSuccess(member)),
    );
  }
}
