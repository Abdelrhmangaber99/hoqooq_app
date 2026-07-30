part of 'client_form_bloc.dart';

abstract class ClientFormEvent extends Equatable {
  const ClientFormEvent();

  @override
  List<Object?> get props => [];
}

class CreateClientSubmitted extends ClientFormEvent {
  final CreateClientRequest request;
  const CreateClientSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}

class UpdateClientSubmitted extends ClientFormEvent {
  final String id;
  final UpdateClientRequest request;
  const UpdateClientSubmitted(this.id, this.request);

  @override
  List<Object?> get props => [id, request];
}
