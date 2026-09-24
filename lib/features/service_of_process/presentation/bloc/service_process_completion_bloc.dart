import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../documents/domain/repository/i_document_repository.dart';
import '../../../lookups/domain/entities/lookup.dart';
import '../../../lookups/domain/entities/lookup_kind.dart';
import '../../../lookups/domain/repository/i_lookup_repository.dart';
import '../../data/models/complete_service_process_request.dart';
import '../../domain/entities/service_process.dart';
import '../../domain/entities/service_status.dart';
import '../../domain/repository/i_service_process_repository.dart';

part 'service_process_completion_event.dart';
part 'service_process_completion_state.dart';

@injectable
class ServiceProcessCompletionBloc
    extends Bloc<ServiceProcessCompletionEvent, ServiceProcessCompletionState> {
  ServiceProcessCompletionBloc(this._documents, this._services, this._lookups)
    : super(ServiceProcessCompletionInitial()) {
    on<LoadServiceCompletionRequested>(_onLoad);
    on<SubmitServiceCompletionRequested>(_onSubmit);
  }

  final IDocumentRepository _documents;
  final IServiceProcessRepository _services;
  final ILookupRepository _lookups;

  Future<void> _onLoad(
    LoadServiceCompletionRequested event,
    Emitter<ServiceProcessCompletionState> emit,
  ) async {
    emit(ServiceProcessCompletionLoading());
    final result = await _lookups.getLookups(kind: LookupKind.documentCategory);
    result.fold(
      (failure) => emit(ServiceProcessCompletionFailure(failure.message)),
      (categories) => emit(ServiceProcessCompletionReady(categories)),
    );
  }

  Future<void> _onSubmit(
    SubmitServiceCompletionRequested event,
    Emitter<ServiceProcessCompletionState> emit,
  ) async {
    final current = state;
    if (current is! ServiceProcessCompletionReady) return;
    if (current.isSubmitting) return;
    emit(current.copyWith(isSubmitting: true, progress: 0, submitError: null));
    final upload = await _documents.uploadDocument(
      filePath: event.filePath,
      caseId: event.process.caseId,
      categoryId: event.categoryId,
      description: event.resultNotes,
      linkedEntityType: 'SERVICE',
      linkedEntityId: event.process.id,
      onSendProgress: (sent, total) {
        if (total > 0) {
          emit(current.copyWith(isSubmitting: true, progress: sent / total));
        }
      },
    );
    await upload.fold(
      (failure) async => emit(
        current.copyWith(isSubmitting: false, submitError: failure.message),
      ),
      (document) async {
        final completion = await _services.complete(
          event.process.id,
          CompleteServiceProcessRequest(
            status: event.status,
            resultNotes: event.resultNotes,
            documentId: document.id,
          ),
        );
        completion.fold(
          (failure) => emit(
            current.copyWith(isSubmitting: false, submitError: failure.message),
          ),
          (process) => emit(ServiceProcessCompletionSuccess(process)),
        );
      },
    );
  }
}
