import 'package:json_annotation/json_annotation.dart';

/// `status` on `GET/POST/PATCH /clients` per API_CONTRACT.md §5. Values
/// seen in the collection's examples: ACTIVE, ARCHIVED, INACTIVE — not
/// documented as exhaustive, so `unknown` is the fallback.
enum ClientStatus {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('ARCHIVED')
  archived,
  @JsonValue('INACTIVE')
  inactive,
  @JsonValue('unknown')
  unknown,
}
