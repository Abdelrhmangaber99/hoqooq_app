import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/document_item.dart';
import '../../domain/repository/i_document_repository.dart';

part 'document_upload_event.dart';
part 'document_upload_state.dart';

/// Powers the upload affordance in `CaseDetailsPage`'s Documents section.
/// Upload-only, matching the real backend capability exactly (`POST
/// /documents/upload`) — no update/delete/download, none of which are real
/// working endpoints server-side (see `IDocumentRepository`).
///
/// Reports send progress via [DocumentUploadInProgress] so the UI can show
/// a determinate progress bar for large files. Does not refetch
/// `CaseDocumentsBloc` itself — same explicit-refetch convention as every
/// other M4 write path; the calling screen refetches on
/// [DocumentUploadSuccess].
@injectable
class DocumentUploadBloc
    extends Bloc<DocumentUploadEvent, DocumentUploadState> {
  final IDocumentRepository _documentRepository;

  DocumentUploadBloc(this._documentRepository)
    : super(DocumentUploadInitial()) {
    on<DocumentUploadRequested>(_onUpload);
  }

  Future<void> _onUpload(
    DocumentUploadRequested event,
    Emitter<DocumentUploadState> emit,
  ) async {
    if (state is DocumentUploadInProgress) return;
    emit(const DocumentUploadInProgress(0));
    final result = await _documentRepository.uploadDocument(
      filePath: event.filePath,
      caseId: event.caseId,
      categoryId: event.categoryId,
      description: event.description,
      linkedEntityType: event.linkedEntityType,
      linkedEntityId: event.linkedEntityId,
      onSendProgress: (sent, total) {
        if (total > 0) emit(DocumentUploadInProgress(sent / total));
      },
    );
    result.fold(
      (failure) => emit(DocumentUploadFailure(failure.message)),
      (document) => emit(DocumentUploadSuccess(document)),
    );
  }
}
