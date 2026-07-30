part of 'clients_bloc.dart';

abstract class ClientsEvent extends Equatable {
  const ClientsEvent();

  @override
  List<Object?> get props => [];
}

class FetchClientsRequested extends ClientsEvent {}

/// `null` means "All statuses".
class ClientsStatusFilterChanged extends ClientsEvent {
  final ClientStatus? status;
  const ClientsStatusFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class ClientsSearchChanged extends ClientsEvent {
  final String query;
  const ClientsSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}
