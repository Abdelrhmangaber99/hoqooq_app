import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/create_client_request.dart';
import '../../data/models/update_client_request.dart';
import '../../domain/entities/client.dart';
import '../../domain/repository/i_client_repository.dart';

part 'client_form_event.dart';
part 'client_form_state.dart';

/// Powers both the Create-Client and Edit-Client screens — a dedicated
/// write-only bloc, sibling to `ClientsBloc`/`ClientDetailsBloc` (read),
/// same precedent as M3's `CaseHearingsBloc`/`CaseDocumentsBloc` being
/// separate from `CaseDetailsBloc`.
///
/// Does not refetch anything itself on success — explicit refetch is the
/// caller's job (the screen listens for `ClientFormSuccess` and triggers
/// `ClientsBloc`/`ClientDetailsBloc` to reload before navigating back),
/// per the project's standing write-completion convention.
@injectable
class ClientFormBloc extends Bloc<ClientFormEvent, ClientFormState> {
  final IClientRepository _clientRepository;

  ClientFormBloc(this._clientRepository) : super(ClientFormInitial()) {
    on<CreateClientSubmitted>(_onCreate);
    on<UpdateClientSubmitted>(_onUpdate);
  }

  Future<void> _onCreate(
    CreateClientSubmitted event,
    Emitter<ClientFormState> emit,
  ) async {
    emit(ClientFormSubmitting());
    final result = await _clientRepository.createClient(event.request);
    result.fold(
      (failure) => emit(ClientFormFailure(failure.message)),
      (client) => emit(ClientFormSuccess(client)),
    );
  }

  Future<void> _onUpdate(
    UpdateClientSubmitted event,
    Emitter<ClientFormState> emit,
  ) async {
    emit(ClientFormSubmitting());
    final result = await _clientRepository.updateClient(
      event.id,
      event.request,
    );
    result.fold(
      (failure) => emit(ClientFormFailure(failure.message)),
      (client) => emit(ClientFormSuccess(client)),
    );
  }
}
