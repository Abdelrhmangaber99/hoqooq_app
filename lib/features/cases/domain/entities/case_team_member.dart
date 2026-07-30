import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../authentication/domain/entities/user.dart';

part 'case_team_member.freezed.dart';
part 'case_team_member.g.dart';

/// Wire shape for entries in the `team[]` array on `GET/POST/PATCH /cases`
/// per API_CONTRACT.md §8 — replaces the previous `assignments[]` shape
/// (which nested an `Employee`, not a `User`, and had a `LEAD`/`SUPPORT`
/// role enum). `role` is left as a raw string here: no example shows any
/// value for it at all this time, unlike the old shape which at least had
/// two observed values. Reuses the authentication feature's `User` entity
/// directly since `team[].user` is the exact same shape as `GET /users/me`.
@freezed
abstract class CaseTeamMember with _$CaseTeamMember {
  const factory CaseTeamMember({
    required String id,
    required String role,
    required User user,
  }) = _CaseTeamMember;

  factory CaseTeamMember.fromJson(Map<String, dynamic> json) =>
      _$CaseTeamMemberFromJson(json);
}
