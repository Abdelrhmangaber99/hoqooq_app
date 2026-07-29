import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/client.dart';
import '../../domain/usecases/get_clients_use_case.dart';

part 'clients_event.dart';
part 'clients_state.dart';

@injectable
class ClientsBloc extends Bloc<ClientsEvent, ClientsState> {
  final GetClientsUseCase _getClientsUseCase;
  String _activeFilter = 'All';
  String _searchQuery = '';

  ClientsBloc(this._getClientsUseCase) : super(ClientsInitial()) {
    on<FetchClientsRequested>((event, emit) async {
      emit(ClientsLoading());
      if (event.filter != null) _activeFilter = event.filter!;
      if (event.searchQuery != null) _searchQuery = event.searchQuery!;

      final result = await _getClientsUseCase.execute(filter: _activeFilter == 'All' ? null : _activeFilter);
      
      result.fold(
        (failure) => emit(ClientsError(failure.message)),
        (clients) {
          var filteredClients = clients;
          if (_searchQuery.isNotEmpty) {
            filteredClients = clients.where((c) => 
              c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.email.toLowerCase().contains(_searchQuery.toLowerCase())
            ).toList();
          }
          emit(ClientsLoaded(filteredClients, activeFilter: _activeFilter, searchQuery: _searchQuery));
        },
      );
    });
  }
}
