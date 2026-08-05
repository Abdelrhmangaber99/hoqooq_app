import '../../../../core/network/api_result.dart';
import '../../data/models/create_hearing_request.dart';
import '../../data/models/update_hearing_request.dart';
import '../entities/hearing.dart';

/// Mirrors API_CONTRACT.md finding I (Hearings). No query parameters exist
/// on `GET /hearings`, so `getHearings` fetches the full tenant
/// collection; per-case filtering is done client-side by `caseId` (same
/// pattern as `ClientDetailsBloc` filtering cases by `clientId` in M2),
/// since there is no server-side `?caseId=` filter.
///
/// `updateHearing` added in M4. `createHearing` added in M5, once `GET
/// /lookups?kind=HEARING_TYPE` (finding K) made `hearingTypeId`
/// populatable — hearing creation was blocked until then.
abstract class IHearingRepository {
  ApiResult<List<Hearing>> getHearings();
  ApiResult<Hearing> createHearing(CreateHearingRequest request);
  ApiResult<Hearing> updateHearing(String id, UpdateHearingRequest request);
}
