import 'package:json_annotation/json_annotation.dart';

/// `accessLevel` on `team[]` entries per API_CONTRACT.md finding O.
///
/// Confirmed from the actual backend source
/// (`src/modules/cases/entities/case-team.entity.ts`'s `CaseAccessLevel`
/// enum). Corrects the earlier `roleOnCase` field name — that name only
/// ever existed as a backward-compatibility type alias for this enum
/// type in the backend source, never as an actual JSON key.
enum CaseAccessLevel {
  @JsonValue('FULL_ACCESS')
  fullAccess,
  @JsonValue('READ_ONLY')
  readOnly,
  @JsonValue('UPLOAD_DOCUMENTS')
  uploadDocuments,
  @JsonValue('ASSIGN_HEARING')
  assignHearing,
  @JsonValue('unknown')
  unknown,
}
