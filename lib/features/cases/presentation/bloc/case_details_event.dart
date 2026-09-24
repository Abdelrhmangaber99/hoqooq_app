part of 'case_details_bloc.dart';

abstract class CaseDetailsEvent extends Equatable {
  const CaseDetailsEvent();

  @override
  List<Object?> get props => [];
}

class FetchCaseDetailsRequested extends CaseDetailsEvent {
  final String id;
  const FetchCaseDetailsRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class ChangeCaseStatusRequested extends CaseDetailsEvent {
  const ChangeCaseStatusRequested(this.id, this.status);

  final String id;
  final CaseStatus status;

  @override
  List<Object?> get props => [id, status];
}
