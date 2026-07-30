part of 'client_form_bloc.dart';

abstract class ClientFormState extends Equatable {
  const ClientFormState();

  @override
  List<Object?> get props => [];
}

class ClientFormInitial extends ClientFormState {}

class ClientFormSubmitting extends ClientFormState {}

class ClientFormSuccess extends ClientFormState {
  final Client client;
  const ClientFormSuccess(this.client);

  @override
  List<Object?> get props => [client];
}

class ClientFormFailure extends ClientFormState {
  final String message;
  const ClientFormFailure(this.message);

  @override
  List<Object?> get props => [message];
}
