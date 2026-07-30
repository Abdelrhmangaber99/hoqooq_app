part of 'case_documents_bloc.dart';

abstract class CaseDocumentsState extends Equatable {
  const CaseDocumentsState();

  @override
  List<Object?> get props => [];
}

class CaseDocumentsInitial extends CaseDocumentsState {}

class CaseDocumentsLoading extends CaseDocumentsState {}

class CaseDocumentsLoaded extends CaseDocumentsState {
  final List<DocumentItem> documents;
  const CaseDocumentsLoaded(this.documents);

  @override
  List<Object?> get props => [documents];
}

class CaseDocumentsError extends CaseDocumentsState {
  final String message;
  const CaseDocumentsError(this.message);

  @override
  List<Object?> get props => [message];
}
