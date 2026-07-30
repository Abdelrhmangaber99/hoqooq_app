import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../cases/domain/entities/legal_case.dart';
import '../../../cases/domain/repository/i_case_repository.dart';
import '../../../users/domain/repository/i_user_repository.dart';
import '../../data/models/create_task_request.dart';
import '../../data/models/update_task_request.dart';
import '../../domain/entities/task_item.dart';
import '../../domain/repository/i_task_repository.dart';

part 'task_form_event.dart';
part 'task_form_state.dart';

/// Powers both the Create-Task and Edit-Task screens (reached from
/// `DashboardPage`'s personal task list). No `Lookup` dependency, unlike
/// Cases/Hearings creation — loads Users (for `assignedToId`) and Cases
/// (for the optional `caseId` link) once as reference data; either
/// degrades to an empty list on failure rather than failing the whole
/// form (both pickers are optional/have a "none" choice).
///
/// Does not refetch anything itself on success — explicit refetch is the
/// caller's job, per the project's standing write-completion convention.
@injectable
class TaskFormBloc extends Bloc<TaskFormEvent, TaskFormState> {
  final ITaskRepository _taskRepository;
  final IUserRepository _userRepository;
  final ICaseRepository _caseRepository;

  TaskFormBloc(this._taskRepository, this._userRepository, this._caseRepository)
    : super(TaskFormInitial()) {
    on<LoadTaskFormReferenceDataRequested>(_onLoad);
    on<CreateTaskSubmitted>(_onCreate);
    on<UpdateTaskSubmitted>(_onUpdate);
  }

  Future<void> _onLoad(
    LoadTaskFormReferenceDataRequested event,
    Emitter<TaskFormState> emit,
  ) async {
    emit(TaskFormLoading());
    final usersResult = await _userRepository.getUsers();
    final casesResult = await _caseRepository.getCases();
    final users = usersResult.fold((_) => const <User>[], (u) => u);
    final cases = casesResult.fold((_) => const <LegalCase>[], (c) => c);
    emit(TaskFormReady(users: users, cases: cases));
  }

  Future<void> _onCreate(
    CreateTaskSubmitted event,
    Emitter<TaskFormState> emit,
  ) async {
    final current = state;
    if (current is! TaskFormReady) return;

    emit(current.copyWith(isSubmitting: true, submitError: null));
    final result = await _taskRepository.createTask(event.request);
    result.fold(
      (failure) => emit(
        current.copyWith(isSubmitting: false, submitError: failure.message),
      ),
      (task) => emit(TaskFormSuccess(task)),
    );
  }

  Future<void> _onUpdate(
    UpdateTaskSubmitted event,
    Emitter<TaskFormState> emit,
  ) async {
    final current = state;
    if (current is! TaskFormReady) return;

    emit(current.copyWith(isSubmitting: true, submitError: null));
    final result = await _taskRepository.updateTask(event.id, event.request);
    result.fold(
      (failure) => emit(
        current.copyWith(isSubmitting: false, submitError: failure.message),
      ),
      (task) => emit(TaskFormSuccess(task)),
    );
  }
}
