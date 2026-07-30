import 'package:json_annotation/json_annotation.dart';

/// `priority` on `GET/POST/PATCH /cases` per API_CONTRACT.md §8. Values
/// seen in the collection's examples: NORMAL, HIGH, URGENT. `LOW` is not
/// observed but included since the other three follow an obvious 4-tier
/// pattern — still not documented as exhaustive, so `unknown` is the
/// fallback for anything else.
enum CasePriority {
  @JsonValue('LOW')
  low,
  @JsonValue('NORMAL')
  normal,
  @JsonValue('HIGH')
  high,
  @JsonValue('URGENT')
  urgent,
  @JsonValue('unknown')
  unknown,
}
