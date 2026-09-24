part of 'case_team_assignment_bloc.dart';

abstract class CaseTeamAssignmentEvent extends Equatable {
  const CaseTeamAssignmentEvent();

  @override
  List<Object?> get props => [];
}

class LoadCaseTeamAssignmentReferenceDataRequested
    extends CaseTeamAssignmentEvent {}

class CaseTeamAssignmentSubmitted extends CaseTeamAssignmentEvent {
  final String caseId;
  final AssignCaseRequest request;
  const CaseTeamAssignmentSubmitted(this.caseId, this.request);

  @override
  List<Object?> get props => [caseId, request];
}

class CaseAccessRevocationSubmitted extends CaseTeamAssignmentEvent {
  final String caseId;
  final String userId;
  const CaseAccessRevocationSubmitted(this.caseId, this.userId);

  @override
  List<Object?> get props => [caseId, userId];
}
