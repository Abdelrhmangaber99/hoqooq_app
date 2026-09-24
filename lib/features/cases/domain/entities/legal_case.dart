import 'package:freezed_annotation/freezed_annotation.dart';
import 'case_priority.dart';
import 'case_party_snapshot.dart';
import 'case_status.dart';
import 'case_team_member.dart';
import 'case_timeline_event.dart';
import 'case_type_lookup.dart';

part 'legal_case.freezed.dart';
part 'legal_case.g.dart';

/// Wire shape for `GET/POST/PATCH /cases` per API_CONTRACT.md §8.
///
/// **Corrected 2026-07-30 (backend-source re-verification, pre-M3):**
/// `CasesController` never applies `plainToInstance`/`ClassSerializerInterceptor`
/// — it returns the raw TypeORM entity, so the actual wire shape is governed
/// by `CasesService.findAll`/`.findOne`'s TypeORM relations/joins, not by the
/// response DTO alone. Case Court selection uses the restored backend
/// `defaultCourtId`; `courtName` remains as a compatibility display snapshot.
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
    required String caseTypeId,
    @JsonKey(unknownEnumValue: CasePriority.unknown)
    required CasePriority priority,
    required DateTime createdAt,
    required DateTime updatedAt,
    CaseClientSnapshot? clientSnapshot,
    List<CaseOpponentSnapshot>? opponentSnapshots,
    CaseTypeLookup? caseType,
    String? title,
    String? courtCaseNumber,
    int? courtCaseYear,
    String? governorateId,
    String? circuitId,
    String? ownerFirmAdminId,
    String? primaryLawyerId,
    String? description,
    String? courtName,
    DateTime? openingDate,
    DateTime? closingDate,
    String? outcomeSummary,
    required List<CaseTeamMember> team,
    @JsonKey(fromJson: _timelineFromJson, includeToJson: false)
    List<CaseTimelineEvent>? timelineEvents,
  }) = _LegalCase;

  factory LegalCase.fromJson(Map<String, dynamic> json) =>
      _$LegalCaseFromJson(_normalizeCaseJson(json));
}

List<CaseTimelineEvent>? _timelineFromJson(List<dynamic>? value) => value
    ?.map((item) => CaseTimelineEvent.fromJson(item as Map<String, dynamic>))
    .toList();

Map<String, dynamic> _normalizeCaseJson(Map<String, dynamic> json) {
  return {
    ...json,
    'caseTypeId': json['caseTypeId'] ?? '',
    'team': json['team'] ?? const <dynamic>[],
  };
}
