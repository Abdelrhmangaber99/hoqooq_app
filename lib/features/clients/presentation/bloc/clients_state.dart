part of 'clients_bloc.dart';

abstract class ClientsState extends Equatable {
  const ClientsState();
  
  @override
  List<Object?> get props => [];
}

class ClientsInitial extends ClientsState {}

class ClientsLoading extends ClientsState {}

class ClientsLoaded extends ClientsState {
  final List<Client> clients;
  final String activeFilter;
  final String searchQuery;
  
  const ClientsLoaded(this.clients, {this.activeFilter = 'All', this.searchQuery = ''});

  @override
  List<Object?> get props => [clients, activeFilter, searchQuery];
}

class ClientsError extends ClientsState {
  final String message;
  const ClientsError(this.message);

  @override
  List<Object?> get props => [message];
}
