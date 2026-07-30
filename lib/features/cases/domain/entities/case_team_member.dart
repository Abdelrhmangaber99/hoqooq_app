import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../authentication/domain/entities/user.dart';

part 'case_team_member.freezed.dart';
part 'case_team_member.g.dart';

/// Wire shape for entries in the `team[]` array on `GET/POST/PATCH /cases`
/// per API_CONTRACT.md §8.
///
/// **Corrected 2026-07-30 (backend-source re-verification, pre-M3):** the
/// real entity (`CaseTeam`, `src/modules/cases/entities/case-team.entity.ts`)
/// names the role field `roleOnCase`, not `role` — the backend's own
/// (never-enforced) `CaseResponseDto` documents `role`, which doesn't match
/// its own entity. `CasesService` only requests `relations: ['team']`, not
/// `'team.user'`, so the nested `user` object is never populated even
/// though `userId` always is — `user` corrected to nullable, `userId` added
/// so a team entry is still identifiable when `user` is absent (which is
/// always, under current backend behavior).
@freezed
abstract class CaseTeamMember with _$CaseTeamMember {
  const factory CaseTeamMember({
    required String id,
    required String roleOnCase,
    required String userId,
    User? user,
  }) = _CaseTeamMember;

  factory CaseTeamMember.fromJson(Map<String, dynamic> json) =>
      _$CaseTeamMemberFromJson(json);
}
