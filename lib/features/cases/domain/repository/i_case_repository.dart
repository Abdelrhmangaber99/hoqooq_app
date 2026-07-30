import '../../../../core/network/api_result.dart';
import '../entities/legal_case.dart';

/// Mirrors API_CONTRACT.md §8 (Cases) — read-only for M2. No query
/// parameters are documented on `GET /cases`, so `getCases` takes none;
/// filtering/search is done client-side in `CasesBloc`.
abstract class ICaseRepository {
  ApiResult<List<LegalCase>> getCases();
  ApiResult<LegalCase> getCaseDetails(String id);
}
