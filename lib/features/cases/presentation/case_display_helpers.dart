import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../di/injection.dart';
import '../../courts/domain/entities/case_type_reference.dart';
import '../../courts/domain/repository/i_court_repository.dart';
import '../domain/entities/case_access_level.dart';
import '../domain/entities/case_priority.dart';
import '../domain/entities/case_status.dart';
import '../domain/entities/case_type_lookup.dart';
import '../domain/entities/legal_case.dart';
import '../domain/entities/case_summary.dart';
import '../domain/repository/i_case_repository.dart';

/// `GET /reference/case-types`, fetched at most once per app run and shared
/// by every case-type label outside the Case form.
///
/// Why a separate fetch is needed: the deployed backend nests `caseType` on a
/// Case as `{id, name}` only (its `LookupResponseDto`), so
/// `CaseTypeLookup.labelFor` has no `labelEn`/`labelAr` to return and always
/// falls back to the unlocalized `name`. The reference list is the only
/// endpoint that carries both labels — the same one the Create-Case dropdown
/// already uses, so details and the form always agree.
Future<List<CaseTypeReference>>? _caseTypesFuture;

Future<List<CaseTypeReference>> loadCaseTypeReferences() {
  final cached = _caseTypesFuture;
  if (cached != null) return cached;
  // Details must remain usable even when optional reference-data wiring is
  // unavailable (for example during a partial startup or an isolated widget
  // test). The Case payload already carries enough data for a fallback label.
  if (!getIt.isRegistered<ICourtRepository>()) {
    return Future.value(const <CaseTypeReference>[]);
  }
  final future = getIt<ICourtRepository>().getCaseTypes().then(
    (result) => result.fold(
      (_) => const <CaseTypeReference>[],
      (items) => items,
    ),
  );
  _caseTypesFuture = future;
  // A failed load must not be cached forever: drop it so the next build
  // retries instead of showing the unlocalized fallback permanently.
  future.then(
    (_) {},
    onError: (_) {
      if (identical(_caseTypesFuture, future)) _caseTypesFuture = null;
    },
  );
  return future;
}

/// Localized case-type label for a Case: the reference list wins (it has both
/// languages), then the nested `caseType.name` the backend does send, then
/// [fallback] when the case carries no type at all.
String caseTypeLabelFor({
  required String languageCode,
  required String? caseTypeId,
  required CaseTypeLookup? caseType,
  required List<CaseTypeReference> caseTypes,
  String fallback = '—',
}) {
  for (final type in caseTypes) {
    if (type.id == caseTypeId) return type.labelFor(languageCode);
  }
  final name = caseType?.name.trim() ?? '';
  return name.isEmpty ? fallback : name;
}

/// Human-readable case name — the case `title` when present, else its type
/// name, and only then the case number. Used where a bare case number read
/// like an opaque id (finance / reports lists).
String caseDisplayName(LegalCase legalCase) {
  final title = legalCase.title?.trim();
  if (title != null && title.isNotEmpty) return title;
  final typeName = legalCase.caseType?.name.trim();
  if (typeName != null && typeName.isNotEmpty) return typeName;
  return legalCase.caseNumber;
}

/// Human-facing judicial reference. Internal Case UUIDs and generated firm
/// references are implementation details on Hearings, Calendar and Reports;
/// users identify a filed Case by its court number and year.
String courtCaseReference({
  required String? courtCaseNumber,
  required int? courtCaseYear,
  String fallback = '—',
}) {
  final number = courtCaseNumber?.trim() ?? '';
  if (number.isNotEmpty && courtCaseYear != null) {
    return '$number / $courtCaseYear';
  }
  if (number.isNotEmpty) return number;
  if (courtCaseYear != null) return courtCaseYear.toString();
  return fallback;
}

String legalCaseCourtReference(LegalCase legalCase) => courtCaseReference(
  courtCaseNumber: legalCase.courtCaseNumber,
  courtCaseYear: legalCase.courtCaseYear,
  fallback: legalCase.caseNumber,
);

String caseSummaryCourtReference(CaseSummary summary) => courtCaseReference(
  courtCaseNumber: summary.courtCaseNumber,
  courtCaseYear: summary.courtCaseYear,
  fallback: summary.caseNumber,
);

/// `GET /cases`, fetched at most once per app run and keyed by case id.
///
/// Activity payloads (Hearings, Tasks, Documents, Finance, Calendar) nest a
/// compact `case` brief that carries only the internal generated
/// `caseNumber`, so a list screen that renders one of those briefs has no
/// court number/year to show even though [caseSummaryCourtReference] would
/// prefer it. `GET /cases` is the only source that carries them, so the
/// brief is resolved against this index instead of being shown as-is.
Future<Map<String, LegalCase>>? _casesByIdFuture;

Future<Map<String, LegalCase>> loadCasesById() {
  final cached = _casesByIdFuture;
  if (cached != null) return cached;
  // Reference data is optional: an isolated widget test (or a partial
  // startup) has no case repository, and must still render.
  if (!getIt.isRegistered<ICaseRepository>()) {
    return Future.value(const <String, LegalCase>{});
  }
  final future = getIt<ICaseRepository>().getCases().then(
    (result) => result.fold(
      (_) => const <String, LegalCase>{},
      (items) => {for (final item in items) item.id: item},
    ),
  );
  _casesByIdFuture = future;
  // A failed load must not be cached forever: drop it so the next build
  // retries instead of showing the internal number permanently.
  future.then(
    (_) {},
    onError: (_) {
      if (identical(_casesByIdFuture, future)) _casesByIdFuture = null;
    },
  );
  return future;
}

/// Judicial reference for a case the caller only knows by id: the court
/// number + year when that Case is loaded, else [fallback] (normally the
/// internal generated number the activity payload carried).
String courtReferenceForCaseId(
  Map<String, LegalCase> casesById,
  String? caseId, {
  String fallback = '—',
}) {
  final legalCase = caseId == null ? null : casesById[caseId];
  if (legalCase == null) return fallback;
  return legalCaseCourtReference(legalCase);
}

/// [courtReferenceForCaseId] for the compact nested `case` brief an activity
/// payload carries: resolves via [casesById] when possible, else keeps the
/// brief's own reference ([caseSummaryCourtReference]).
String courtReferenceForSummary(
  Map<String, LegalCase> casesById,
  CaseSummary? summary,
) {
  if (summary == null) return '—';
  return courtReferenceForCaseId(
    casesById,
    summary.id,
    fallback: caseSummaryCourtReference(summary),
  );
}

String caseStatusLabel(BuildContext context, CaseStatus status) {
  switch (status) {
    case CaseStatus.draft:
      return context.tr('draft');
    case CaseStatus.active:
      return context.tr('active');
    case CaseStatus.suspended:
      return context.tr('suspended');
    case CaseStatus.closed:
      return context.tr('closed');
    case CaseStatus.archived:
      return context.tr('archived');
    case CaseStatus.unknown:
      return context.tr('unknown');
  }
}

Color caseStatusColor(CaseStatus status) {
  switch (status) {
    case CaseStatus.draft:
      return AppColors.textHint;
    case CaseStatus.active:
      return AppColors.success;
    case CaseStatus.suspended:
      return AppColors.warning;
    case CaseStatus.closed:
      return AppColors.textSecondary;
    case CaseStatus.archived:
      return AppColors.warning;
    case CaseStatus.unknown:
      return AppColors.textHint;
  }
}

String casePriorityLabel(BuildContext context, CasePriority priority) {
  switch (priority) {
    case CasePriority.low:
      return context.tr('low');
    case CasePriority.normal:
      return context.tr('normal');
    case CasePriority.high:
      return context.tr('high');
    case CasePriority.urgent:
      return context.tr('urgent');
    case CasePriority.unknown:
      return context.tr('unknown');
  }
}

Color casePriorityColor(CasePriority priority) {
  switch (priority) {
    case CasePriority.low:
      return AppColors.info;
    case CasePriority.normal:
      return AppColors.textSecondary;
    case CasePriority.high:
      return AppColors.warning;
    case CasePriority.urgent:
      return AppColors.error;
    case CasePriority.unknown:
      return AppColors.textHint;
  }
}

String caseAccessLevelLabel(BuildContext context, CaseAccessLevel level) {
  switch (level) {
    case CaseAccessLevel.fullAccess:
      return context.tr('full_access');
    case CaseAccessLevel.readOnly:
      return context.tr('read_only');
    case CaseAccessLevel.uploadDocuments:
      return context.tr('upload_documents');
    case CaseAccessLevel.assignHearing:
      return context.tr('assign_hearing');
    case CaseAccessLevel.unknown:
      return context.tr('unknown');
  }
}

Color caseAccessLevelColor(CaseAccessLevel level) {
  switch (level) {
    case CaseAccessLevel.fullAccess:
      return AppColors.success;
    case CaseAccessLevel.readOnly:
      return AppColors.textSecondary;
    case CaseAccessLevel.uploadDocuments:
      return AppColors.info;
    case CaseAccessLevel.assignHearing:
      return AppColors.warning;
    case CaseAccessLevel.unknown:
      return AppColors.textHint;
  }
}
