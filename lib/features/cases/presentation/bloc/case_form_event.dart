part of 'case_form_bloc.dart';

abstract class CaseFormEvent extends Equatable {
  const CaseFormEvent();

  @override
  List<Object?> get props => [];
}

class LoadCaseFormReferenceDataRequested extends CaseFormEvent {
  const LoadCaseFormReferenceDataRequested();
}

class LoadCaseCourtsRequested extends CaseFormEvent {
  const LoadCaseCourtsRequested(this.governorateId);

  final String governorateId;

  @override
  List<Object?> get props => [governorateId];
}

class LoadCaseCircuitsRequested extends CaseFormEvent {
  const LoadCaseCircuitsRequested(this.courtId);

  final String courtId;

  @override
  List<Object?> get props => [courtId];
}

class CreateCaseSubmitted extends CaseFormEvent {
  final CreateCaseRequest request;
  const CreateCaseSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}

class UpdateCaseSubmitted extends CaseFormEvent {
  final String id;
  final UpdateCaseRequest request;
  const UpdateCaseSubmitted(this.id, this.request);

  @override
  List<Object?> get props => [id, request];
}
