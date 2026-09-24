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
  final String? actionId;
  final String? actionError;
  final DownloadedDocument? downloadedDocument;
  const CaseDocumentsLoaded(
    this.documents, {
    this.actionId,
    this.actionError,
    this.downloadedDocument,
  });

  @override
  List<Object?> get props => [
    documents,
    actionId,
    actionError,
    downloadedDocument,
  ];
}

class CaseDocumentsError extends CaseDocumentsState {
  final String message;
  final bool isForbidden;
  const CaseDocumentsError(this.message, {this.isForbidden = false});

  @override
  List<Object?> get props => [message, isForbidden];
}
