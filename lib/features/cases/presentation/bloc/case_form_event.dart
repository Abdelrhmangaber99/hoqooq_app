part of 'case_form_bloc.dart';

abstract class CaseFormEvent extends Equatable {
  const CaseFormEvent();

  @override
  List<Object?> get props => [];
}

class LoadCaseFormReferenceDataRequested extends CaseFormEvent {}

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
