import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../documents/domain/entities/document_item.dart';
import '../../../documents/domain/repository/i_document_repository.dart';

part 'case_documents_event.dart';
part 'case_documents_state.dart';

/// Powers `CaseDetailsPage`'s Documents section. `GET /documents` has no
/// `?caseId=` filter (API_CONTRACT.md finding I), so this fetches the full
/// tenant collection and filters client-side by `caseId` — same pattern as
/// `CaseHearingsBloc`. Metadata-only: `GET /documents/{id}/download` is a
/// stub that doesn't return real file bytes, so there is no download
/// action wired here.
@injectable
class CaseDocumentsBloc extends Bloc<CaseDocumentsEvent, CaseDocumentsState> {
  final IDocumentRepository _documentRepository;

  CaseDocumentsBloc(this._documentRepository) : super(CaseDocumentsInitial()) {
    on<FetchCaseDocumentsRequested>(_onFetch);
  }

  Future<void> _onFetch(
    FetchCaseDocumentsRequested event,
    Emitter<CaseDocumentsState> emit,
  ) async {
    emit(CaseDocumentsLoading());
    final result = await _documentRepository.getDocuments();
    result.fold(
      (failure) => emit(CaseDocumentsError(failure.message)),
      (documents) => emit(
        CaseDocumentsLoaded(
          documents.where((d) => d.caseId == event.caseId).toList(),
        ),
      ),
    );
  }
}
