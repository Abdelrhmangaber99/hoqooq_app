import '../../../../core/network/api_result.dart';
import '../../data/models/create_client_request.dart';
import '../../data/models/update_client_request.dart';
import '../entities/client.dart';

/// Mirrors API_CONTRACT.md §5 (Clients). No query parameters are
/// documented on `GET /clients`, so `getClients` takes none; filtering/
/// search is done client-side in `ClientsBloc`.
///
/// `createClient`/`updateClient` added in M4. Known issue, not a client-
/// side concern: `ClientsService.create` doesn't override a client-
/// supplied `tenantId` (see API_CONTRACT.md finding Q) — `findOne`/
/// `.update`/`.remove` were fixed to scope by tenant in a later backend
/// pass, `create` was not; re-flagged to the backend team, not something
/// this app can work around at the repository layer.
abstract class IClientRepository {
  ApiResult<List<Client>> getClients();
  ApiResult<Client> getClientDetails(String id);
  ApiResult<Client> createClient(CreateClientRequest request);
  ApiResult<Client> updateClient(String id, UpdateClientRequest request);
}
