import 'package:equatable/equatable.dart';
import 'case_finance_status.dart';

/// Accepts a JSON number or a numeric string (Postgres `numeric` columns
/// serialize as strings); null/garbage degrades to 0 rather than throwing.
double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

class CaseFinanceSummaryRow extends Equatable {
  const CaseFinanceSummaryRow({
    required this.caseId,
    required this.caseNumber,
    required this.agreedFee,
    required this.paid,
    required this.remaining,
    required this.status,
  });

  final String caseId;
  final String caseNumber;
  final double agreedFee;
  final double paid;
  final double remaining;
  final CaseFinanceStatus status;

  factory CaseFinanceSummaryRow.fromJson(Map<String, dynamic> json) {
    return CaseFinanceSummaryRow(
      caseId: json['caseId'] as String? ?? '',
      caseNumber: json['caseNumber'] as String? ?? '',
      // `numeric` columns can arrive as JSON strings; accept both so one
      // odd row can't take down the whole finance list.
      agreedFee: _toDouble(json['agreedFee']),
      paid: _toDouble(json['paid']),
      remaining: _toDouble(json['remaining']),
      status: caseFinanceStatusFromJson(json['status']),
    );
  }

  @override
  List<Object?> get props => [
    caseId,
    caseNumber,
    agreedFee,
    paid,
    remaining,
    status,
  ];
}

class FinanceSummary extends Equatable {
  const FinanceSummary({
    required this.totalCaseValue,
    required this.totalCollected,
    required this.totalOutstanding,
    required this.paidCases,
    required this.partialCases,
    required this.unpaidCases,
    required this.cases,
  });

  final double totalCaseValue;
  final double totalCollected;
  final double totalOutstanding;
  final int paidCases;
  final int partialCases;
  final int unpaidCases;
  final List<CaseFinanceSummaryRow> cases;

  factory FinanceSummary.fromJson(Map<String, dynamic> json) {
    final rawCases = (json['cases'] as List<dynamic>?) ?? const [];
    return FinanceSummary(
      totalCaseValue: _toDouble(json['totalCaseValue']),
      totalCollected: _toDouble(json['totalCollected']),
      totalOutstanding: _toDouble(json['totalOutstanding']),
      paidCases: (json['paidCases'] as num?)?.toInt() ?? 0,
      partialCases: (json['partialCases'] as num?)?.toInt() ?? 0,
      unpaidCases: (json['unpaidCases'] as num?)?.toInt() ?? 0,
      cases: rawCases
          .whereType<Map<String, dynamic>>()
          .map(CaseFinanceSummaryRow.fromJson)
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
    totalCaseValue,
    totalCollected,
    totalOutstanding,
    paidCases,
    partialCases,
    unpaidCases,
    cases,
  ];
}
