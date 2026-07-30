part of 'case_hearings_bloc.dart';

abstract class CaseHearingsEvent extends Equatable {
  const CaseHearingsEvent();

  @override
  List<Object?> get props => [];
}

class FetchCaseHearingsRequested extends CaseHearingsEvent {
  final String caseId;
  const FetchCaseHearingsRequested(this.caseId);

  @override
  List<Object?> get props => [caseId];
}
