import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../cases/domain/entities/case_summary.dart';
import '../../../cases/domain/entities/court.dart';
import 'hearing_status.dart';

part 'hearing.freezed.dart';
part 'hearing.g.dart';

/// Wire shape for `GET/PATCH /hearings` per API_CONTRACT.md finding I.
///
/// `HearingsController` never applies `plainToInstance`/
/// `ClassSerializerInterceptor` — the real response is the raw entity as
/// loaded by `HearingsService`'s `relations: ['case', 'court']`, not the
/// (unenforced) `HearingResponseDto`, which documents `caseId`/`courtId` as
/// IDs only. `case`/`court` are nested here because those two relations are
/// actually requested; `circuitId`/`hearingTypeId` stay ID-only since
/// `circuit`/`hearingType` are never loaded.
@freezed
abstract class Hearing with _$Hearing {
  const factory Hearing({
    required String id,
    required String caseId,
    @JsonKey(name: 'case') CaseSummary? caseSummary,
    required String courtId,
    Court? court,
    String? circuitId,
    required String hearingTypeId,
    required DateTime scheduledAt,
    String? judgeName,
    @JsonKey(unknownEnumValue: HearingStatus.unknown)
    required HearingStatus status,
    String? outcomeText,
    DateTime? nextHearingAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Hearing;

  factory Hearing.fromJson(Map<String, dynamic> json) =>
      _$HearingFromJson(json);
}
