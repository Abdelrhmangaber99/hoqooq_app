import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../authentication/domain/entities/user.dart';
import 'case_access_level.dart';

part 'case_team_member.freezed.dart';
part 'case_team_member.g.dart';

/// Wire shape for entries in the `team[]` array on `GET/POST/PATCH /cases`
/// per API_CONTRACT.md §8.
///
/// **Corrected 2026-08-05 (API_CONTRACT.md finding O) — supersedes the
/// earlier `roleOnCase` naming.** The real entity
/// (`CaseTeam`, `src/modules/cases/entities/case-team.entity.ts`) names
/// the field `accessLevel`, a real enum (`CaseAccessLevel`) — `roleOnCase`
/// only ever existed as a backward-compatibility *type alias* for that
/// enum type in the backend source, never a JSON key; the earlier fix
/// (M3 pre-planning) misread the backend's own never-enforced
/// `CaseResponseDto`, which itself documents the wrong name.
///
/// **Also corrected 2026-08-05:** `CasesService` now explicitly joins
/// `team.user` (previously only `'team'`, so `user` was always absent) —
/// `user` stays nullable defensively, but is expected to be populated now.
@freezed
abstract class CaseTeamMember with _$CaseTeamMember {
  const factory CaseTeamMember({
    required String id,
    @JsonKey(unknownEnumValue: CaseAccessLevel.unknown)
    required CaseAccessLevel accessLevel,
    required String userId,
    User? user,
  }) = _CaseTeamMember;

  factory CaseTeamMember.fromJson(Map<String, dynamic> json) =>
      _$CaseTeamMemberFromJson(json);
}
