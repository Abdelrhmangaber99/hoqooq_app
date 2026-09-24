import 'package:equatable/equatable.dart';
import 'case_finance_status.dart';
import 'payment_record.dart';
import '../usecases/finance_calculator.dart';

/// Case Finance view model (PRD v2.0 §6.2.11 / §7.8 BR-027).
///
/// `agreedFee` is nullable — a Case MAY store an agreed fee (BR-027), and a
/// missing fee must render as an explicit "no fee set" state, never as 0.
/// `paid`/`remaining` are derived from the payment records themselves (sum of
/// non-reversed payments), so ledger totals can never drift from source data.
class CaseFinanceDetail extends Equatable {
  const CaseFinanceDetail({
    required this.caseId,
    required this.agreedFee,
    required this.payments,
  });

  final String caseId;

  /// `null` when the Case has no fee recorded yet — not the same as 0.
  final double? agreedFee;
  final List<PaymentRecord> payments;

  /// Sum of valid non-reversed payment records (BR-027).
  double get paid => FinanceCalculator.calculatePaidAmount(payments);

  /// max(agreedFee - paid, 0) — null when no fee is set, since "remaining"
  /// is meaningless without an agreed fee.
  double? get remaining => agreedFee == null
      ? null
      : FinanceCalculator.calculateRemainingAmount(agreedFee, paid);

  /// Paid / partial / unpaid derived from fee + payments (BR-027).
  CaseFinanceStatus get status =>
      FinanceCalculator.deriveStatus(agreedFee, paid);

  factory CaseFinanceDetail.fromJson(Map<String, dynamic> json) {
    final rawPayments = (json['payments'] as List<dynamic>?) ?? const [];
    return CaseFinanceDetail(
      // Tolerant of a missing/null caseId: the ledger should still render
      // the money data it did receive instead of throwing "Null is not a
      // subtype of String" and blanking the screen.
      caseId: json['caseId'] as String? ?? '',
      agreedFee: json['agreedFee'] is num
          ? (json['agreedFee'] as num).toDouble()
          : double.tryParse(json['agreedFee']?.toString() ?? ''),
      payments: rawPayments
          .whereType<Map<String, dynamic>>()
          .map(PaymentRecord.fromJson)
          .toList(),
    );
  }

  @override
  List<Object?> get props => [caseId, agreedFee, payments];
}
