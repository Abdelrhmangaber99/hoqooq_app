part of 'case_tasks_bloc.dart';

sealed class CaseTasksState extends Equatable {
  const CaseTasksState();
  @override
  List<Object?> get props => [];
}

class CaseTasksInitial extends CaseTasksState {}

class CaseTasksLoading extends CaseTasksState {}

class CaseTasksLoaded extends CaseTasksState {
  const CaseTasksLoaded(this.items, {this.actionId, this.actionError});
  final List<TaskItem> items;
  final String? actionId;
  final String? actionError;

  CaseTasksLoaded copyWith({String? actionId, String? actionError}) =>
      CaseTasksLoaded(items, actionId: actionId, actionError: actionError);

  @override
  List<Object?> get props => [items, actionId, actionError];
}

class CaseTasksError extends CaseTasksState {
  const CaseTasksError(this.message, {this.isForbidden = false});
  final String message;
  final bool isForbidden;
  @override
  List<Object?> get props => [message, isForbidden];
}
