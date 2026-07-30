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
/// Rebuilt 2026-07-30 for a backend update: replaces the earlier
/// UI-mockup shape (`attorneyName`/`hearingsCount`/`documentsCount`/
/// `daysOpen`, none of which the real API ever returned) with the actual
/// fields — much closer to the BRD's case data dictionary now
/// (agreedFee/priority/openingDate/closingDate/primaryLawyerId/
/// caseTypeId). Named `LegalCase`, not `Case`, because `case` is a Dart
/// reserved word.
///
/// Note what's now gone entirely, not just deferred: `notes[]` and
/// `POST /cases/{id}/notes` were both removed in this update, and there is
/// no endpoint anywhere to add a `team[]` member. See PLAN.md M2 framing.
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
    required String primaryLawyerId,
    required User primaryLawyer,
    required CaseTypeLookup caseType,
    required String defaultCourtId,
    required Court defaultCourt,
    DateTime? openingDate,
    DateTime? closingDate,
    String? outcomeSummary,
    double? agreedFee,
    required List<CaseTeamMember> team,
  }) = _LegalCase;

  factory LegalCase.fromJson(Map<String, dynamic> json) =>
      _$LegalCaseFromJson(json);
}
