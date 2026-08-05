import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/case_access_level.dart';

part 'assign_case_request.freezed.dart';
part 'assign_case_request.g.dart';

/// Request body for `POST /cases/{id}/assignments` per `AssignCaseDto`.
/// Restored 2026-08-05 after being removed pre-M2 (API_CONTRACT.md finding
/// P) — this is now the only way to add a `team[]` member, since
/// `primaryLawyer` no longer exists on the `Case` entity at all (finding
/// N). `role` (a legacy alias the backend also accepts) is intentionally
/// not sent — `accessLevel` is the real field.
@freezed
abstract class AssignCaseRequest with _$AssignCaseRequest {
  const factory AssignCaseRequest({
    required String userId,
    required CaseAccessLevel accessLevel,
  }) = _AssignCaseRequest;

  factory AssignCaseRequest.fromJson(Map<String, dynamic> json) =>
      _$AssignCaseRequestFromJson(json);
}
