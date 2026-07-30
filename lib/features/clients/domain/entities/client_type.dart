import 'package:json_annotation/json_annotation.dart';

/// `type` on `GET/POST/PATCH /clients` per API_CONTRACT.md §5. Values
/// seen in the collection's examples: INDIVIDUAL, COMPANY — not documented
/// as exhaustive, so `unknown` is the fallback.
enum ClientType {
  @JsonValue('INDIVIDUAL')
  individual,
  @JsonValue('COMPANY')
  company,
  @JsonValue('unknown')
  unknown,
}
