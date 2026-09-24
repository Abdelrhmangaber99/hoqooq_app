import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/service_process.dart';
import '../../domain/repository/i_service_process_repository.dart';

part 'case_service_process_event.dart';
part 'case_service_process_state.dart';

@injectable
class CaseServiceProcessBloc
    extends Bloc<CaseServiceProcessEvent, CaseServiceProcessState> {
  CaseServiceProcessBloc(this._repository)
    : super(CaseServiceProcessInitial()) {
    on<FetchCaseServiceProcessesRequested>(_onFetch);
    on<CancelServiceProcessRequested>(_onCancel);
  }

  final IServiceProcessRepository _repository;

  Future<void> _onFetch(
    FetchCaseServiceProcessesRequested event,
    Emitter<CaseServiceProcessState> emit,
  ) async {
    emit(CaseServiceProcessLoading());
    final result = await _repository.getForCase(event.caseId);
    result.fold(
      (failure) => emit(
        CaseServiceProcessError(
          failure.message,
          isForbidden: failure is ForbiddenFailure,
        ),
      ),
      (items) => emit(CaseServiceProcessLoaded(items)),
    );
  }

  Future<void> _onCancel(
    CancelServiceProcessRequested event,
    Emitter<CaseServiceProcessState> emit,
  ) async {
    final current = state;
    if (current is! CaseServiceProcessLoaded) return;
    emit(current.copyWith(cancellingId: event.id));
    final result = await _repository.cancel(event.id);
    await result.fold(
      (failure) async => emit(current.copyWith(actionError: failure.message)),
      (_) async {
        final refreshed = await _repository.getForCase(event.caseId);
        refreshed.fold(
          (failure) => emit(current.copyWith(actionError: failure.message)),
          (items) => emit(CaseServiceProcessLoaded(items)),
        );
      },
    );
  }
}
