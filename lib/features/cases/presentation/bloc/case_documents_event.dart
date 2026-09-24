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

class UploadDocumentVersionRequested extends CaseDocumentsEvent {
  const UploadDocumentVersionRequested({
    required this.documentId,
    required this.caseId,
    required this.filePath,
    this.changeSummary,
  });
  final String documentId;
  final String caseId;
  final String filePath;
  final String? changeSummary;
  @override
  List<Object?> get props => [documentId, caseId, filePath, changeSummary];
}

class DownloadDocumentRequested extends CaseDocumentsEvent {
  const DownloadDocumentRequested({
    required this.documentId,
    required this.fileName,
  });
  final String documentId;
  final String fileName;
  @override
  List<Object?> get props => [documentId, fileName];
}

class ArchiveDocumentRequested extends CaseDocumentsEvent {
  const ArchiveDocumentRequested({
    required this.documentId,
    required this.caseId,
  });
  final String documentId;
  final String caseId;
  @override
  List<Object?> get props => [documentId, caseId];
}
