import 'package:json_annotation/json_annotation.dart';

/// `kind` on `GET /lookups?kind=...` per API_CONTRACT.md finding K.
///
/// Confirmed exhaustive from the actual backend source
/// (`src/modules/settings/entities/lookup.entity.ts`'s `LookupKind` enum).
enum LookupKind {
  @JsonValue('CASE_TYPE')
  caseType,
  @JsonValue('HEARING_TYPE')
  hearingType,
  @JsonValue('DOCUMENT_CATEGORY')
  documentCategory,
  @JsonValue('EXPENSE_CATEGORY')
  expenseCategory,
  @JsonValue('unknown')
  unknown,
}

/// Reverse of the `@JsonValue` mapping above — needed because a query
/// parameter isn't serialized through json_serializable's generated
/// `toJson()` the way a request body field is.
String lookupKindWireValue(LookupKind kind) {
  switch (kind) {
    case LookupKind.caseType:
      return 'CASE_TYPE';
    case LookupKind.hearingType:
      return 'HEARING_TYPE';
    case LookupKind.documentCategory:
      return 'DOCUMENT_CATEGORY';
    case LookupKind.expenseCategory:
      return 'EXPENSE_CATEGORY';
    case LookupKind.unknown:
      return 'unknown';
  }
}
