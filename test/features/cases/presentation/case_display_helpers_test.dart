import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/cases/domain/entities/case_priority.dart';
import 'package:hqooq/features/cases/domain/entities/case_status.dart';
import 'package:hqooq/features/cases/domain/entities/case_summary.dart';
import 'package:hqooq/features/cases/domain/entities/legal_case.dart';
import 'package:hqooq/features/cases/presentation/case_display_helpers.dart';

/// A Case whose judicial reference (court number + year) differs from the
/// internal generated `caseNumber`, so a call that accidentally returns the
/// internal number is visible as a failure rather than a coincidence.
LegalCase _legalCase({String? courtCaseNumber, int? courtCaseYear}) =>
    LegalCase(
      id: 'c1',
      tenantId: 't1',
      caseNumber: 'HQ-2026-000001',
      courtCaseNumber: courtCaseNumber,
      courtCaseYear: courtCaseYear,
      status: CaseStatus.active,
      caseTypeId: 'ct1',
      priority: CasePriority.high,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      team: const [],
    );

CaseSummary _summary({String? courtCaseNumber, int? courtCaseYear}) =>
    CaseSummary(
      id: 'c1',
      tenantId: 't1',
      caseNumber: 'HQ-2026-000001',
      courtCaseNumber: courtCaseNumber,
      courtCaseYear: courtCaseYear,
      status: CaseStatus.active,
      clientId: 'cl1',
      caseTypeId: 'ct1',
      priority: CasePriority.high,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  group('courtCaseReference', () {
    test('joins a court number and year', () {
      expect(
        courtCaseReference(courtCaseNumber: '2026/1234', courtCaseYear: 2026),
        '2026/1234 / 2026',
      );
    });

    test('uses whichever part is present', () {
      expect(
        courtCaseReference(courtCaseNumber: '2026/1234', courtCaseYear: null),
        '2026/1234',
      );
      expect(
        courtCaseReference(courtCaseNumber: null, courtCaseYear: 2026),
        '2026',
      );
    });

    test('falls back when neither part is present', () {
      expect(
        courtCaseReference(
          courtCaseNumber: null,
          courtCaseYear: null,
          fallback: 'HQ-2026-000001',
        ),
        'HQ-2026-000001',
      );
      expect(
        courtCaseReference(courtCaseNumber: '  ', courtCaseYear: null),
        '—',
      );
    });
  });

  group('entity court references', () {
    test('legalCaseCourtReference prefers the court number + year', () {
      expect(
        legalCaseCourtReference(
          _legalCase(courtCaseNumber: '2026/1234', courtCaseYear: 2026),
        ),
        '2026/1234 / 2026',
      );
    });

    test('legalCaseCourtReference falls back to the internal number', () {
      expect(legalCaseCourtReference(_legalCase()), 'HQ-2026-000001');
    });

    test('caseSummaryCourtReference mirrors the legal-case helper', () {
      expect(
        caseSummaryCourtReference(
          _summary(courtCaseNumber: '2026/1234', courtCaseYear: 2026),
        ),
        '2026/1234 / 2026',
      );
      expect(caseSummaryCourtReference(_summary()), 'HQ-2026-000001');
    });
  });

  group('courtReferenceForCaseId', () {
    test('resolves a loaded case by id', () {
      final cases = {
        'c1': _legalCase(courtCaseNumber: '2026/1234', courtCaseYear: 2026),
      };
      expect(
        courtReferenceForCaseId(cases, 'c1', fallback: 'HQ-2026-000001'),
        '2026/1234 / 2026',
      );
    });

    test('keeps the fallback for an unknown or null id', () {
      expect(
        courtReferenceForCaseId(const {}, 'missing', fallback: 'HQ-1'),
        'HQ-1',
      );
      expect(courtReferenceForCaseId(const {}, null, fallback: 'HQ-1'), 'HQ-1');
    });
  });

  group('courtReferenceForSummary', () {
    test('prefers the loaded case over the brief it was given', () {
      final cases = {
        'c1': _legalCase(courtCaseNumber: '2026/1234', courtCaseYear: 2026),
      };
      expect(
        courtReferenceForSummary(cases, _summary(courtCaseNumber: '9999')),
        '2026/1234 / 2026',
      );
    });

    test('falls back to the brief reference when the case is not loaded', () {
      expect(
        courtReferenceForSummary(
          const {},
          _summary(courtCaseNumber: '9999', courtCaseYear: 2020),
        ),
        '9999 / 2020',
      );
      expect(courtReferenceForSummary(const {}, _summary()), 'HQ-2026-000001');
      expect(courtReferenceForSummary(const {}, null), '—');
    });
  });

  group('loadCasesById', () {
    setUp(() async {
      await getIt.reset();
    });

    test('returns an empty index when no case repository is wired', () async {
      expect(await loadCasesById(), isEmpty);
    });
  });
}
