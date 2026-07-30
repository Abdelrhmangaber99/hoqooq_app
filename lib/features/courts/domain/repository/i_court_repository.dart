import '../../../../core/network/api_result.dart';
import '../../../cases/domain/entities/court.dart';

/// `GET /courts` — the one real, browsable reference-data endpoint M4's
/// write forms can rely on for a court picker (contrast: no endpoint lists
/// `Lookup` rows at all, see API_CONTRACT.md finding J — `caseTypeId`/
/// `hearingTypeId` stay immutable in every edit form for that reason).
/// Reuses the `Court` entity already defined in the cases feature — same
/// wire shape, no need for a second model.
abstract class ICourtRepository {
  ApiResult<List<Court>> getCourts();
}
