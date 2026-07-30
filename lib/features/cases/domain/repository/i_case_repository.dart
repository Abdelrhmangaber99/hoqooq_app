import '../../../../core/network/api_result.dart';
import '../../data/models/update_case_request.dart';
import '../entities/legal_case.dart';

/// Mirrors API_CONTRACT.md §8 (Cases). No query parameters are documented
/// on `GET /cases`, so `getCases` takes none; filtering/search is done
/// client-side in `CasesBloc`.
///
/// `updateCase` added in M4 — no `createCase`: `caseTypeId` is required on
/// create and references the unbrowsable `Lookup` entity (finding J), so
/// case creation stays out of scope until a lookup-listing endpoint exists.
abstract class ICaseRepository {
  ApiResult<List<LegalCase>> getCases();
  ApiResult<LegalCase> getCaseDetails(String id);
  ApiResult<LegalCase> updateCase(String id, UpdateCaseRequest request);
}
