import '../../../../core/network/api_result.dart';
import '../entities/lookup.dart';
import '../entities/lookup_kind.dart';

/// `GET /lookups?kind=...` per API_CONTRACT.md finding K (added 2026-08-05,
/// resolves the previous absence of any Lookup-listing endpoint — the exact
/// gap that blocked Case/Hearing creation through M4). Tenant-scoped.
abstract class ILookupRepository {
  ApiResult<List<Lookup>> getLookups({required LookupKind kind});
}
