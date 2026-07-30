part of 'task_form_bloc.dart';

abstract class TaskFormState extends Equatable {
  const TaskFormState();

  @override
  List<Object?> get props => [];
}

class TaskFormInitial extends TaskFormState {}

class TaskFormLoading extends TaskFormState {}

class TaskFormReady extends TaskFormState {
  final List<User> users;
  final List<LegalCase> cases;
  final bool isSubmitting;
  final String? submitError;

  const TaskFormReady({
    required this.users,
    required this.cases,
    this.isSubmitting = false,
    this.submitError,
  });

  TaskFormReady copyWith({bool? isSubmitting, String? submitError}) {
    return TaskFormReady(
      users: users,
      cases: cases,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError,
    );
  }

  @override
  List<Object?> get props => [users, cases, isSubmitting, submitError];
}

class TaskFormSuccess extends TaskFormState {
  final TaskItem task;
  const TaskFormSuccess(this.task);

  @override
  List<Object?> get props => [task];
}
