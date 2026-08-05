import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../clients/domain/entities/client.dart';
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
/// by `CasesService.findAll`/`.findOne`'s TypeORM relations/joins
/// (`client`, `defaultCourt`, `team`, `team.user`, `opponents`,
/// `timelineEvents`), not by the (also never-enforced) `CaseResponseDto`.
/// `caseType` is NOT among them — never returned at all, despite
/// `caseTypeId` always being present (resolve the label client-side via
/// the `lookups` feature instead). `defaultCourt`/`defaultCourtId` are
/// genuinely nullable on the entity itself (a case may have no default
/// court), not just because of relation loading.
///
/// **Corrected 2026-08-05 (API_CONTRACT.md finding N) — not a relation-
/// loading question this time:** `primaryLawyer`/`primaryLawyerId` are
/// gone from the backend schema entirely, confirmed by reading
/// `case.entity.ts` directly — removed here to match, not left nullable.
/// The "primary lawyer" concept has been replaced by `team[]`, addable via
/// `POST /cases/:id/assignments` (see finding P).
///
/// Named `LegalCase`, not `Case`, because `case` is a Dart reserved word.
/// Note what's gone entirely, not just deferred: `notes[]` on this
/// response (though `POST /cases/{id}/notes` exists again as of
/// 2026-08-05, `GET /cases/:id` still doesn't return them — see finding
/// P). See PLAN.md M2 framing and M5 scope.
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
