part of 'clients_bloc.dart';

abstract class ClientsEvent extends Equatable {
  const ClientsEvent();

  @override
  List<Object?> get props => [];
}

class FetchClientsRequested extends ClientsEvent {
  final String? filter;
  final String? searchQuery;
  const FetchClientsRequested({this.filter, this.searchQuery});

  @override
  List<Object?> get props => [filter, searchQuery];
}
