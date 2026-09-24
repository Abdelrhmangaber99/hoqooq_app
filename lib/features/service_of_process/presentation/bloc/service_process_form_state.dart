part of 'service_process_form_bloc.dart';

sealed class ServiceProcessFormState extends Equatable {
  const ServiceProcessFormState();
  @override
  List<Object?> get props => [];
}

class ServiceProcessFormInitial extends ServiceProcessFormState {}

class ServiceProcessFormLoading extends ServiceProcessFormState {}

class ServiceProcessFormReady extends ServiceProcessFormState {
  const ServiceProcessFormReady({
    required this.courts,
    required this.methods,
    this.isSubmitting = false,
    this.submitError,
  });
  final List<Court> courts;
  final List<Lookup> methods;
  final bool isSubmitting;
  final String? submitError;

  ServiceProcessFormReady copyWith({
    bool isSubmitting = false,
    String? submitError,
  }) => ServiceProcessFormReady(
    courts: courts,
    methods: methods,
    isSubmitting: isSubmitting,
    submitError: submitError,
  );

  @override
  List<Object?> get props => [courts, methods, isSubmitting, submitError];
}

class ServiceProcessFormSuccess extends ServiceProcessFormState {
  const ServiceProcessFormSuccess(this.item);
  final ServiceProcess item;
  @override
  List<Object?> get props => [item];
}
