import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/case_priority.dart';
import '../../domain/entities/case_status.dart';

part 'update_case_request.freezed.dart';
part 'update_case_request.g.dart';

/// Request body for `PATCH /cases/{id}` per `UpdateCaseDto`
/// (`PartialType(CreateCaseDto)` server-side).
///
/// Deliberately excludes `caseTypeId`, `caseNumber`, and `clientId` —
/// `caseNumber`/`clientId` aren't meant to change after creation.
/// `caseTypeId` could technically be re-selected now that `GET
/// /lookups?kind=CASE_TYPE` exists (API_CONTRACT.md finding K), but stays
/// read-only-redisplay in the edit form per the M5 scope decision — only
/// *creation* was unblocked, changing an existing case's type after the
/// fact wasn't asked for and isn't obviously safe (case numbering/filing
/// may assume it's immutable). Revisit if a real need comes up. No
/// `primaryLawyerId` — removed from the backend schema entirely
/// (finding N); team membership changes go through
/// `POST /cases/:id/assignments` instead. Every field is
/// `@JsonKey(includeIfNull: false)` for the same partial-PATCH reason as
/// `UpdateClientRequest` — `CasesService.update` does a TypeORM `merge()`,
/// which would null out untouched columns if the key were present at all.
@freezed
abstract class UpdateCaseRequest with _$UpdateCaseRequest {
  const factory UpdateCaseRequest({
    @JsonKey(includeIfNull: false) String? defaultCourtId,
    @JsonKey(includeIfNull: false) CaseStatus? status,
    @JsonKey(includeIfNull: false) DateTime? openingDate,
    @JsonKey(includeIfNull: false) DateTime? closingDate,
    @JsonKey(includeIfNull: false) String? outcomeSummary,
    @JsonKey(includeIfNull: false) double? agreedFee,
    @JsonKey(includeIfNull: false) CasePriority? priority,
  }) = _UpdateCaseRequest;

  factory UpdateCaseRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCaseRequestFromJson(json);
}
