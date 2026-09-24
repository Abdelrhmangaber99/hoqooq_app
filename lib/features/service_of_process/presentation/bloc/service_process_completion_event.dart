part of 'service_process_completion_bloc.dart';

sealed class ServiceProcessCompletionEvent extends Equatable {
  const ServiceProcessCompletionEvent();
  @override
  List<Object?> get props => [];
}

class LoadServiceCompletionRequested extends ServiceProcessCompletionEvent {}

class SubmitServiceCompletionRequested extends ServiceProcessCompletionEvent {
  const SubmitServiceCompletionRequested({
    required this.process,
    required this.status,
    required this.resultNotes,
    required this.filePath,
    required this.categoryId,
  });

  final ServiceProcess process;
  final ServiceStatus status;
  final String resultNotes;
  final String filePath;
  final String categoryId;

  @override
  List<Object?> get props => [
    process,
    status,
    resultNotes,
    filePath,
    categoryId,
  ];
}
