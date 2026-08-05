import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/client_status.dart';
import '../../domain/usecases/get_clients_use_case.dart';

part 'clients_event.dart';
part 'clients_state.dart';

/// No query parameters are documented on `GET /clients` (API_CONTRACT.md
/// §5), so status filtering and search are both done client-side here
/// over the full fetched list — per PLAN.md M2 decision #5.
@injectable
class ClientsBloc extends Bloc<ClientsEvent, ClientsState> {
  final GetClientsUseCase _getClientsUseCase;

  List<Client> _allClients = [];
  ClientStatus? _statusFilter;
  String _searchQuery = '';

  ClientsBloc(this._getClientsUseCase) : super(ClientsInitial()) {
    on<FetchClientsRequested>(_onFetch);
    on<ClientsStatusFilterChanged>(_onStatusFilterChanged);
    on<ClientsSearchChanged>(_onSearchChanged);
  }

  Future<void> _onFetch(
    FetchClientsRequested event,
    Emitter<ClientsState> emit,
  ) async {
    emit(ClientsLoading());
    final result = await _getClientsUseCase.execute();
    result.fold(
      (failure) {
        emit(
          ClientsError(
            failure.message,
            isForbidden: failure is ForbiddenFailure,
          ),
        );
      },
      (clients) {
        _allClients = clients;
        emit(_buildLoadedState());
      },
    );
  }

  void _onStatusFilterChanged(
    ClientsStatusFilterChanged event,
    Emitter<ClientsState> emit,
  ) {
    _statusFilter = event.status;
    emit(_buildLoadedState());
  }

  void _onSearchChanged(
    ClientsSearchChanged event,
    Emitter<ClientsState> emit,
  ) {
    _searchQuery = event.query;
    emit(_buildLoadedState());
  }

  ClientsState _buildLoadedState() {
    var filtered = _allClients;
    if (_statusFilter != null) {
      filtered = filtered.where((c) => c.status == _statusFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (c) =>
                c.fullName.toLowerCase().contains(query) ||
                c.emails.any((e) => e.toLowerCase().contains(query)) ||
                c.phones.any((p) => p.contains(query)),
          )
          .toList();
    }
    return ClientsLoaded(
      filtered,
      statusFilter: _statusFilter,
      searchQuery: _searchQuery,
    );
  }
}
