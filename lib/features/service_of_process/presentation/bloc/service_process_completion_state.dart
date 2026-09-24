part of 'service_process_completion_bloc.dart';

sealed class ServiceProcessCompletionState extends Equatable {
  const ServiceProcessCompletionState();
  @override
  List<Object?> get props => [];
}

class ServiceProcessCompletionInitial extends ServiceProcessCompletionState {}

class ServiceProcessCompletionLoading extends ServiceProcessCompletionState {}

class ServiceProcessCompletionReady extends ServiceProcessCompletionState {
  const ServiceProcessCompletionReady(
    this.categories, {
    this.isSubmitting = false,
    this.progress = 0,
    this.submitError,
  });
  final List<Lookup> categories;
  final bool isSubmitting;
  final double progress;
  final String? submitError;

  ServiceProcessCompletionReady copyWith({
    bool isSubmitting = false,
    double progress = 0,
    String? submitError,
  }) => ServiceProcessCompletionReady(
    categories,
    isSubmitting: isSubmitting,
    progress: progress,
    submitError: submitError,
  );

  @override
  List<Object?> get props => [categories, isSubmitting, progress, submitError];
}

class ServiceProcessCompletionSuccess extends ServiceProcessCompletionState {
  const ServiceProcessCompletionSuccess(this.process);
  final ServiceProcess process;
  @override
  List<Object?> get props => [process];
}

class ServiceProcessCompletionFailure extends ServiceProcessCompletionState {
  const ServiceProcessCompletionFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
