import '../../../../core/network/api_result.dart';
import '../../data/models/create_client_request.dart';
import '../../data/models/update_client_request.dart';
import '../entities/client.dart';

/// Mirrors API_CONTRACT.md §5 (Clients). No query parameters are
/// documented on `GET /clients`, so `getClients` takes none; filtering/
/// search is done client-side in `ClientsBloc`.
///
/// `createClient`/`updateClient` added in M4. Known issue, not a client-
/// side concern: `ClientsService.findOne`/`.update`/`.remove` don't scope
/// by tenant (see API_CONTRACT.md finding J) — the backend team is aware
/// and fixing this server-side; M4 proceeds without waiting on it.
abstract class IClientRepository {
  ApiResult<List<Client>> getClients();
  ApiResult<Client> getClientDetails(String id);
  ApiResult<Client> createClient(CreateClientRequest request);
  ApiResult<Client> updateClient(String id, UpdateClientRequest request);
}
