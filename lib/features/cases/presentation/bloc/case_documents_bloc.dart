import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../documents/domain/entities/document_item.dart';
import '../../../documents/domain/entities/downloaded_document.dart';
import '../../../documents/domain/repository/i_document_repository.dart';

part 'case_documents_event.dart';
part 'case_documents_state.dart';

/// Powers Case Details using the backend's Case-scoped Document query.
@injectable
class CaseDocumentsBloc extends Bloc<CaseDocumentsEvent, CaseDocumentsState> {
  final IDocumentRepository _documentRepository;

  CaseDocumentsBloc(this._documentRepository) : super(CaseDocumentsInitial()) {
    on<FetchCaseDocumentsRequested>(_onFetch);
    on<UploadDocumentVersionRequested>(_onUploadVersion);
    on<DownloadDocumentRequested>(_onDownload);
    on<ArchiveDocumentRequested>(_onArchive);
  }

  Future<void> _onFetch(
    FetchCaseDocumentsRequested event,
    Emitter<CaseDocumentsState> emit,
  ) async {
    emit(CaseDocumentsLoading());
    await _load(event.caseId, emit);
  }

  Future<void> _load(String caseId, Emitter<CaseDocumentsState> emit) async {
    final result = await _documentRepository.getDocuments(caseId);
    result.fold(
      (failure) => emit(
        CaseDocumentsError(
          failure.message,
          isForbidden: failure is ForbiddenFailure,
        ),
      ),
      (documents) => emit(CaseDocumentsLoaded(documents)),
    );
  }

  Future<void> _onUploadVersion(
    UploadDocumentVersionRequested event,
    Emitter<CaseDocumentsState> emit,
  ) async {
    final current = state;
    if (current is! CaseDocumentsLoaded) return;
    emit(CaseDocumentsLoaded(current.documents, actionId: event.documentId));
    final result = await _documentRepository.uploadVersion(
      documentId: event.documentId,
      filePath: event.filePath,
      changeSummary: event.changeSummary,
    );
    await result.fold(
      (failure) async => emit(
        CaseDocumentsLoaded(current.documents, actionError: failure.message),
      ),
      (_) async => _load(event.caseId, emit),
    );
  }

  Future<void> _onDownload(
    DownloadDocumentRequested event,
    Emitter<CaseDocumentsState> emit,
  ) async {
    final current = state;
    if (current is! CaseDocumentsLoaded) return;
    emit(CaseDocumentsLoaded(current.documents, actionId: event.documentId));
    final result = await _documentRepository.downloadDocument(
      event.documentId,
      event.fileName,
    );
    result.fold(
      (failure) => emit(
        CaseDocumentsLoaded(current.documents, actionError: failure.message),
      ),
      (download) => emit(
        CaseDocumentsLoaded(current.documents, downloadedDocument: download),
      ),
    );
  }

  Future<void> _onArchive(
    ArchiveDocumentRequested event,
    Emitter<CaseDocumentsState> emit,
  ) async {
    final current = state;
    if (current is! CaseDocumentsLoaded) return;
    emit(CaseDocumentsLoaded(current.documents, actionId: event.documentId));
    final result = await _documentRepository.archiveDocument(event.documentId);
    await result.fold(
      (failure) async => emit(
        CaseDocumentsLoaded(current.documents, actionError: failure.message),
      ),
      (_) async => _load(event.caseId, emit),
    );
  }
}
