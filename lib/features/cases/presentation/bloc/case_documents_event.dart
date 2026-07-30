part of 'case_documents_bloc.dart';

abstract class CaseDocumentsEvent extends Equatable {
  const CaseDocumentsEvent();

  @override
  List<Object?> get props => [];
}

class FetchCaseDocumentsRequested extends CaseDocumentsEvent {
  final String caseId;
  const FetchCaseDocumentsRequested(this.caseId);

  @override
  List<Object?> get props => [caseId];
}
