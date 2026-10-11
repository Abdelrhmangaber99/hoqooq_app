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
    String? courtCaseNumber,
    int? courtCaseYear,
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
      _$CaseSummaryFromJson(_normalizeSummaryJson(json));
}

/// Nested `case` objects (Hearings, Tasks, Documents, Finance, Calendar) are
/// the raw deployed Case row, whose shape dropped `clientId` and `priority`
/// — parties live in `clients[]` now, and `priority` is not returned at all.
/// Both are `required` here, so their absence threw inside `fromJson`, which
/// bypasses the repositories' `on DioException` catch and killed the calling
/// bloc before it could emit — a permanent spinner instead of data.
Map<String, dynamic> _normalizeSummaryJson(Map<String, dynamic> json) {
  final clients = json['clients'];
  final firstClient = clients is List && clients.first is Map
      ? clients.first
      : null;
  const epoch = '1970-01-01T00:00:00.000Z';
  return {
    ...json,
    // Activity endpoints are allowed to return a compact Case reference.
    // Keep that useful reference renderable instead of requiring every
    // column from the full Case entity to be present.
    'id': json['id']?.toString() ?? '',
    'tenantId': json['tenantId']?.toString() ?? '',
    'caseNumber': json['caseNumber']?.toString() ?? '',
    'courtCaseNumber': json['courtCaseNumber']?.toString(),
    'courtCaseYear': json['courtCaseYear'] is num
        ? (json['courtCaseYear'] as num).toInt()
        : int.tryParse(json['courtCaseYear']?.toString() ?? ''),
    'caseTypeId': json['caseTypeId']?.toString() ?? '',
    'clientId':
        json['clientId'] ??
        (firstClient is Map ? firstClient['id'] : null) ??
        '',
    'priority': json['priority'] ?? 'unknown',
    'status': json['status'] ?? 'unknown',
    'createdAt': json['createdAt'] is String ? json['createdAt'] : epoch,
    'updatedAt': json['updatedAt'] is String ? json['updatedAt'] : epoch,
  };
}
