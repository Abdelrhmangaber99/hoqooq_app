import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../clients/domain/entities/client.dart';
import '../../../authentication/domain/entities/user.dart';
import 'case_priority.dart';
import 'case_status.dart';
import 'case_team_member.dart';
import 'case_type_lookup.dart';
import 'court.dart';

part 'legal_case.freezed.dart';
part 'legal_case.g.dart';

/// Wire shape for `GET/POST/PATCH /cases` per API_CONTRACT.md §8.
///
/// **Corrected 2026-07-30 (backend-source re-verification, pre-M3):**
/// `CasesController` never applies `plainToInstance`/`ClassSerializerInterceptor`
/// — it returns the raw TypeORM entity, so the actual wire shape is governed
/// by `CasesService.findAll`/`.findOne`'s TypeORM `relations: [...]` array
/// (`['client', 'defaultCourt', 'team', 'opponents', 'timelineEvents']`),
/// not by the (also never-enforced) `CaseResponseDto`. `caseType` and
/// `primaryLawyer` are NOT in that list — they are never returned at all,
/// despite `caseTypeId`/`primaryLawyerId` always being present. Both were
/// wrongly `required` before this fix, which would throw against a real
/// backend. `defaultCourt`/`defaultCourtId` are genuinely nullable on the
/// entity itself (a case may have no default court), not just because of
/// relation loading — corrected to nullable for that reason.
///
/// Named `LegalCase`, not `Case`, because `case` is a Dart reserved word.
/// Note what's gone entirely, not just deferred: `notes[]` and
/// `POST /cases/{id}/notes` were both removed in an earlier backend update,
/// and there is no endpoint anywhere to add a `team[]` member. See
/// PLAN.md M2 framing.
@freezed
abstract class LegalCase with _$LegalCase {
  const factory LegalCase({
    required String id,
    required String tenantId,
    required String caseNumber,
    @JsonKey(unknownEnumValue: CaseStatus.unknown) required CaseStatus status,
    required String clientId,
    required String caseTypeId,
    @JsonKey(unknownEnumValue: CasePriority.unknown)
    required CasePriority priority,
    required DateTime createdAt,
    required DateTime updatedAt,
    required Client client,
    String? primaryLawyerId,
    User? primaryLawyer,
    CaseTypeLookup? caseType,
    String? defaultCourtId,
    Court? defaultCourt,
    DateTime? openingDate,
    DateTime? closingDate,
    String? outcomeSummary,
    double? agreedFee,
    required List<CaseTeamMember> team,
  }) = _LegalCase;

  factory LegalCase.fromJson(Map<String, dynamic> json) =>
      _$LegalCaseFromJson(json);
}
