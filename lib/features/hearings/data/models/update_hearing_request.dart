import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/hearing_status.dart';

part 'update_hearing_request.freezed.dart';
part 'update_hearing_request.g.dart';

/// Request body for `PATCH /hearings/{id}` per `UpdateHearingDto`
/// (`PartialType(CreateHearingDto)` server-side).
///
/// Deliberately excludes `caseId`, `hearingTypeId`, and `circuitId` —
/// `hearingTypeId` could technically be re-selected now that `GET
/// /lookups?kind=HEARING_TYPE` exists (API_CONTRACT.md finding K), but
/// stays read-only-redisplay in the edit form per the M5 scope decision,
/// same reasoning as `UpdateCaseRequest`'s `caseTypeId` exclusion — only
/// *creation* was unblocked, not retroactively changing an existing
/// hearing's type. `circuitId` references `CourtCircuit`, which still has
/// no controller at all (finding J, unchanged); `caseId` isn't meant to
/// change after creation. "Complete a hearing" (per spec) is just
/// `status: completed` + `outcomeText` through this same PATCH — there's
/// no dedicated endpoint. Every field is `@JsonKey(includeIfNull: false)`
/// for the same partial-PATCH reason as
/// `UpdateClientRequest`/`UpdateCaseRequest`.
@freezed
abstract class UpdateHearingRequest with _$UpdateHearingRequest {
  const factory UpdateHearingRequest({
    @JsonKey(includeIfNull: false) String? courtId,
    @JsonKey(includeIfNull: false) DateTime? scheduledAt,
    @JsonKey(includeIfNull: false) String? judgeName,
    @JsonKey(includeIfNull: false) HearingStatus? status,
    @JsonKey(includeIfNull: false) String? outcomeText,
    @JsonKey(includeIfNull: false) DateTime? nextHearingAt,
  }) = _UpdateHearingRequest;

  factory UpdateHearingRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateHearingRequestFromJson(json);
}
