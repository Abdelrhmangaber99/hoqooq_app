import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/task_item.dart';
import '../../domain/repository/i_task_repository.dart';

part 'case_tasks_event.dart';
part 'case_tasks_state.dart';

@injectable
class CaseTasksBloc extends Bloc<CaseTasksEvent, CaseTasksState> {
  CaseTasksBloc(this._repository) : super(CaseTasksInitial()) {
    on<FetchCaseTasksRequested>(_onFetch);
    on<CompleteTaskRequested>(_onComplete);
    on<CancelTaskRequested>(_onCancel);
  }

  final ITaskRepository _repository;

  Future<void> _onFetch(
    FetchCaseTasksRequested event,
    Emitter<CaseTasksState> emit,
  ) async {
    emit(CaseTasksLoading());
    await _load(event.caseId, emit);
  }

  Future<void> _load(String caseId, Emitter<CaseTasksState> emit) async {
    final result = await _repository.getTasks();
    result.fold(
      (failure) => emit(
        CaseTasksError(
          failure.message,
          isForbidden: failure is ForbiddenFailure,
        ),
      ),
      (items) => emit(
        CaseTasksLoaded(items.where((item) => item.caseId == caseId).toList()),
      ),
    );
  }

  Future<void> _onComplete(
    CompleteTaskRequested event,
    Emitter<CaseTasksState> emit,
  ) async {
    final current = state;
    if (current is! CaseTasksLoaded) return;
    emit(current.copyWith(actionId: event.id));
    final result = await _repository.completeTask(
      event.id,
      event.completionNote,
    );
    await result.fold(
      (failure) async => emit(current.copyWith(actionError: failure.message)),
      (_) async => _load(event.caseId, emit),
    );
  }

  Future<void> _onCancel(
    CancelTaskRequested event,
    Emitter<CaseTasksState> emit,
  ) async {
    final current = state;
    if (current is! CaseTasksLoaded) return;
    emit(current.copyWith(actionId: event.id));
    final result = await _repository.cancelTask(event.id);
    await result.fold(
      (failure) async => emit(current.copyWith(actionError: failure.message)),
      (_) async => _load(event.caseId, emit),
    );
  }
}
