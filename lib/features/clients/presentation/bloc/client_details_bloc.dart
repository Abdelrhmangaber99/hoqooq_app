import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../cases/domain/entities/legal_case.dart';
import '../../../cases/domain/repository/i_case_repository.dart';
import '../../domain/entities/client.dart';
import '../../domain/repository/i_client_repository.dart';

part 'client_details_event.dart';
part 'client_details_state.dart';

/// Calls the repository directly (`GET /clients/{id}`) rather than through
/// a dedicated use case — same precedent as `CaseDetailsBloc`.
///
/// There is no `GET /clients/{id}/cases` endpoint and no documented
/// `?clientId=` filter on `GET /cases` (API_CONTRACT.md §8) — per PLAN.md
/// M2 decision #4, this fetches the full case list and filters
/// client-side by `clientId`. Doesn't scale, but shows real data; revisit
/// if a server-side filter or sub-resource turns up.
@injectable
class ClientDetailsBloc extends Bloc<ClientDetailsEvent, ClientDetailsState> {
  final IClientRepository _clientRepository;
  final ICaseRepository _caseRepository;

  ClientDetailsBloc(this._clientRepository, this._caseRepository)
    : super(ClientDetailsInitial()) {
    on<FetchClientDetailsRequested>(_onFetch);
  }

  Future<void> _onFetch(
    FetchClientDetailsRequested event,
    Emitter<ClientDetailsState> emit,
  ) async {
    emit(ClientDetailsLoading());
    final clientResult = await _clientRepository.getClientDetails(event.id);

    await clientResult.fold(
      (failure) async => emit(
        ClientDetailsError(
          failure.message,
          isForbidden: failure is ForbiddenFailure,
        ),
      ),
      (client) async {
        // If the cases fetch fails, don't fail the whole screen over a
        // secondary section — show the client with an empty case list.
        final casesResult = await _caseRepository.getCases();
        final cases = casesResult.fold(
          (_) => const <LegalCase>[],
          (allCases) => allCases.where((c) => c.clientId == client.id).toList(),
        );
        emit(ClientDetailsLoaded(client, cases));
      },
    );
  }
}
