import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/hearing_status.dart';

part 'update_hearing_request.freezed.dart';
part 'update_hearing_request.g.dart';

/// Request body for `PATCH /hearings/{id}` per `UpdateHearingDto`
/// (`PartialType(CreateHearingDto)` server-side).
///
/// Deliberately excludes `caseId`, `hearingTypeId`, and `circuitId` —
/// `hearingTypeId` references the unbrowsable `Lookup` entity
/// (API_CONTRACT.md finding J, same reason `caseTypeId` stays read-only on
/// `UpdateCaseRequest`); `circuitId` references `CourtCircuit`, which has
/// no controller at all (finding J); `caseId` isn't meant to change after
/// creation. "Complete a hearing" (per spec) is just `status: completed` +
/// `outcomeText` through this same PATCH — there's no dedicated endpoint.
/// Every field is `@JsonKey(includeIfNull: false)` for the same
/// partial-PATCH reason as `UpdateClientRequest`/`UpdateCaseRequest`.
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
