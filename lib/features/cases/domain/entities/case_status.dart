import 'package:json_annotation/json_annotation.dart';

/// `status` on `GET/POST/PATCH /cases` per API_CONTRACT.md §8. Values seen
/// in the collection's examples: DRAFT, ACTIVE, ARCHIVED — not documented
/// as exhaustive (no OpenAPI schema backs this collection), so `unknown`
/// is the fallback for anything else a live server returns.
enum CaseStatus {
  @JsonValue('DRAFT')
  draft,
  @JsonValue('ACTIVE')
  active,
  @JsonValue('ARCHIVED')
  archived,
  @JsonValue('unknown')
  unknown,
}
