import 'package:freezed_annotation/freezed_annotation.dart';
import 'case_priority.dart';
import 'case_status.dart';

part 'case_summary.freezed.dart';
part 'case_summary.g.dart';

/// Thin `case` shape nested inside Hearings/Tasks/Documents/Finance
/// invoices/`/calendar/timeline` responses (per API_CONTRACT.md §8's M3
/// pre-planning finding I; Finance reuse added M6, finding R).
///
/// Not the full `LegalCase` — `HearingsService`/`TasksService`/
/// `DocumentsService`/`FinanceService` only request `relations: ['case', ...]`,
/// which loads `Case`'s own columns but does NOT cascade to `Case`'s own
/// relations (`client`, `team`, etc.) — those stay
/// unpopulated even though `LegalCase` marks `client`/`team` as required.
/// Reusing `LegalCase` here would throw on real data for the same reason
/// the M2 regression did.
@freezed
abstract class CaseSummary with _$CaseSummary {
  const factory CaseSummary({
    required String id,
    required String tenantId,
    required String caseNumber,
    @JsonKey(unknownEnumValue: CaseStatus.unknown) required CaseStatus status,
    required String clientId,
    required String caseTypeId,
    String? courtName,
    @JsonKey(unknownEnumValue: CasePriority.unknown)
    required CasePriority priority,
    DateTime? openingDate,
    DateTime? closingDate,
    String? outcomeSummary,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CaseSummary;

  factory CaseSummary.fromJson(Map<String, dynamic> json) =>
      _$CaseSummaryFromJson(json);
}
