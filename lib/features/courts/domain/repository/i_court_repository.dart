import '../../../../core/network/api_result.dart';
import '../../../cases/domain/entities/court.dart';

/// `GET /courts` — a real, browsable reference-data endpoint for a court
/// picker. Note: as of 2026-08-05, `Lookup` rows (`caseTypeId`/
/// `hearingTypeId`) are also browsable via `GET /lookups?kind=...`
/// (API_CONTRACT.md finding K) — this repository predates that and stays
/// focused on `Court` specifically; see the `lookups` feature for the
/// other reference-data source. Reuses the `Court` entity already defined
/// in the cases feature — same wire shape, no need for a second model.
abstract class ICourtRepository {
  ApiResult<List<Court>> getCourts();
}
