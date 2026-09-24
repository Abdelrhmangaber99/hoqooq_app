import 'package:freezed_annotation/freezed_annotation.dart';

part 'assign_case_request.freezed.dart';
part 'assign_case_request.g.dart';

/// Request body for a v2 Case capability-set update.
/// Restored 2026-08-05 after being removed pre-M2 (API_CONTRACT.md finding
/// P) — this is now the only way to add a `team[]` member, since
/// `primaryLawyer` no longer exists on the `Case` entity at all (finding
/// N). `role` (a legacy alias the backend also accepts) is intentionally
/// not sent — `accessLevel` is the real field.
@freezed
abstract class AssignCaseRequest with _$AssignCaseRequest {
  const factory AssignCaseRequest({
    @JsonKey(includeToJson: false) required String userId,
    required List<String> capabilities,
  }) = _AssignCaseRequest;

  factory AssignCaseRequest.fromJson(Map<String, dynamic> json) =>
      _$AssignCaseRequestFromJson(json);
}
