import 'package:json_annotation/json_annotation.dart';

/// `status` on `GET/PATCH /hearings` — confirmed exhaustive from the real
/// backend entity (`src/modules/hearings/entities/hearing.entity.ts`), not
/// the standalone `enums/hearing-status.enum.ts` file (confirmed dead code
/// via `grep -rn "enums/hearing-status" src/` finding zero importers — that
/// file has `POSTPONED` instead of `ADJOURNED`/no `CANCELLED`, and must not
/// be used).
enum HearingStatus {
  @JsonValue('SCHEDULED')
  scheduled,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('POSTPONED')
  adjourned,
  @JsonValue('MISSED')
  missed,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('unknown')
  unknown,
}
