import '../../../../core/network/api_result.dart';
import '../entities/hearing.dart';

/// Mirrors API_CONTRACT.md finding I (Hearings) — read-only for M3. No
/// query parameters exist on `GET /hearings`, so `getHearings` fetches the
/// full tenant collection; per-case filtering is done client-side by
/// `caseId` (same pattern as `ClientDetailsBloc` filtering cases by
/// `clientId` in M2), since there is no server-side `?caseId=` filter.
abstract class IHearingRepository {
  ApiResult<List<Hearing>> getHearings();
}
