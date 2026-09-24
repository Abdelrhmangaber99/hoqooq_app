part of 'service_process_form_bloc.dart';

sealed class ServiceProcessFormEvent extends Equatable {
  const ServiceProcessFormEvent();
  @override
  List<Object?> get props => [];
}

class LoadServiceProcessFormRequested extends ServiceProcessFormEvent {
  const LoadServiceProcessFormRequested(this.governorateId);
  final String? governorateId;
  @override
  List<Object?> get props => [governorateId];
}

class CreateServiceProcessSubmitted extends ServiceProcessFormEvent {
  const CreateServiceProcessSubmitted(this.request);
  final CreateServiceProcessRequest request;
  @override
  List<Object?> get props => [request];
}

class UpdateServiceProcessSubmitted extends ServiceProcessFormEvent {
  const UpdateServiceProcessSubmitted(this.id, this.request);
  final String id;
  final UpdateServiceProcessRequest request;
  @override
  List<Object?> get props => [id, request];
}
