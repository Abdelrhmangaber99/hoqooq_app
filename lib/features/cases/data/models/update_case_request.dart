import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/case_priority.dart';
import '../../domain/entities/case_status.dart';

part 'update_case_request.freezed.dart';
part 'update_case_request.g.dart';

/// Request body for `PATCH /cases/{id}` per `UpdateCaseDto`
/// (`PartialType(CreateCaseDto)` server-side).
///
/// Deliberately excludes `caseTypeId`, `caseNumber`, and `clientId` —
/// `caseTypeId` references the `Lookup` entity, which has no listing
/// endpoint anywhere (API_CONTRACT.md finding J), so there's no way to
/// offer a valid alternative in an edit form; it stays read-only.
/// `caseNumber`/`clientId` aren't meant to change after creation. Every
/// field is `@JsonKey(includeIfNull: false)` for the same partial-PATCH
/// reason as `UpdateClientRequest` — `CasesService.update` does a TypeORM
/// `merge()`, which would null out untouched columns if the key were
/// present at all.
@freezed
abstract class UpdateCaseRequest with _$UpdateCaseRequest {
  const factory UpdateCaseRequest({
    @JsonKey(includeIfNull: false) String? primaryLawyerId,
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
