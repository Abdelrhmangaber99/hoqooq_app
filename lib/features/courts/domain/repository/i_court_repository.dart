import '../../../../core/network/api_result.dart';
import '../../../cases/domain/entities/court.dart';
import '../entities/court_circuit.dart';
import '../entities/case_type_reference.dart';
import '../entities/governorate.dart';

/// `GET /courts` — a real, browsable reference-data endpoint for a court
/// picker. Note: as of 2026-08-05, `Lookup` rows (`caseTypeId`/
/// `hearingTypeId`) are also browsable via `GET /lookups?kind=...`
/// (API_CONTRACT.md finding K) — this repository predates that and stays
/// focused on `Court` specifically; see the `lookups` feature for the
/// other reference-data source. Reuses the `Court` entity already defined
/// in the cases feature — same wire shape, no need for a second model.
abstract class ICourtRepository {
  ApiResult<List<Governorate>> getGovernorates();
  ApiResult<List<CaseTypeReference>> getCaseTypes();
  /// Courts are dependent reference data in v2. A null governorate returns
  /// no options rather than falling back to the removed tenant-wide endpoint.
  ApiResult<List<Court>> getCourts([String? governorateId]);
  ApiResult<List<CourtCircuit>> getCircuits(String courtId);
}
