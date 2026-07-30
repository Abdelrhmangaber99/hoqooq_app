import '../../../../core/network/api_result.dart';
import '../entities/client.dart';

/// Mirrors API_CONTRACT.md §5 (Clients) — read-only for M2. No query
/// parameters are documented on `GET /clients`, so `getClients` takes
/// none; filtering/search is done client-side in `ClientsBloc`. No
/// `createClient` — M2 is read-only, and nothing calls it.
abstract class IClientRepository {
  ApiResult<List<Client>> getClients();
  ApiResult<Client> getClientDetails(String id);
}
