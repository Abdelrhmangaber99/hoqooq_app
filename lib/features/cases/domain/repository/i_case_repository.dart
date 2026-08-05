import '../../../../core/network/api_result.dart';
import '../../data/models/assign_case_request.dart';
import '../../data/models/create_case_request.dart';
import '../../data/models/update_case_request.dart';
import '../entities/case_team_member.dart';
import '../entities/legal_case.dart';

/// Mirrors API_CONTRACT.md §8 (Cases). No query parameters are documented
/// on `GET /cases`, so `getCases` takes none; filtering/search is done
/// client-side in `CasesBloc`.
///
/// `updateCase` added in M4. `createCase`/`assignTeamMember` added in M5,
/// once `GET /lookups?kind=CASE_TYPE` (finding K) and
/// `POST /cases/:id/assignments` (finding P) both became real/available —
/// case creation was blocked until then for lack of any way to populate a
/// valid `caseTypeId`.
abstract class ICaseRepository {
  ApiResult<List<LegalCase>> getCases();
  ApiResult<LegalCase> getCaseDetails(String id);
  ApiResult<LegalCase> createCase(CreateCaseRequest request);
  ApiResult<LegalCase> updateCase(String id, UpdateCaseRequest request);
  ApiResult<CaseTeamMember> assignTeamMember(
    String caseId,
    AssignCaseRequest request,
  );
}
