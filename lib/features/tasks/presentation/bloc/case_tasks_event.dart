part of 'case_tasks_bloc.dart';

sealed class CaseTasksEvent extends Equatable {
  const CaseTasksEvent();
  @override
  List<Object?> get props => [];
}

class FetchCaseTasksRequested extends CaseTasksEvent {
  const FetchCaseTasksRequested(this.caseId);
  final String caseId;
  @override
  List<Object?> get props => [caseId];
}

class CompleteTaskRequested extends CaseTasksEvent {
  const CompleteTaskRequested({
    required this.id,
    required this.caseId,
    required this.completionNote,
  });
  final String id;
  final String caseId;
  final String completionNote;
  @override
  List<Object?> get props => [id, caseId, completionNote];
}

class CancelTaskRequested extends CaseTasksEvent {
  const CancelTaskRequested({required this.id, required this.caseId});
  final String id;
  final String caseId;
  @override
  List<Object?> get props => [id, caseId];
}
