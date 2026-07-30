part of 'task_form_bloc.dart';

abstract class TaskFormEvent extends Equatable {
  const TaskFormEvent();

  @override
  List<Object?> get props => [];
}

class LoadTaskFormReferenceDataRequested extends TaskFormEvent {}

class CreateTaskSubmitted extends TaskFormEvent {
  final CreateTaskRequest request;
  const CreateTaskSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}

class UpdateTaskSubmitted extends TaskFormEvent {
  final String id;
  final UpdateTaskRequest request;
  const UpdateTaskSubmitted(this.id, this.request);

  @override
  List<Object?> get props => [id, request];
}
