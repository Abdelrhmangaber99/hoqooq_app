import 'package:json_annotation/json_annotation.dart';

/// `status` on `GET/POST/PATCH /cases` per API_CONTRACT.md §8.
///
/// Confirmed exhaustive from the actual backend source
/// (`src/modules/cases/entities/case.entity.ts`'s `CaseStatus` enum) —
/// `unknown` is still kept as a fallback in case the backend adds a value
/// later without the app being rebuilt, not because this list is in doubt.
enum CaseStatus {
  @JsonValue('DRAFT')
  draft,
  @JsonValue('ACTIVE')
  active,
  @JsonValue('SUSPENDED')
  suspended,
  @JsonValue('CLOSED')
  closed,
  @JsonValue('ARCHIVED')
  archived,
  @JsonValue('unknown')
  unknown,
}
