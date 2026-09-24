import 'package:equatable/equatable.dart';
import 'payment_method.dart';

class PaymentRecord extends Equatable {
  const PaymentRecord({
    required this.id,
    required this.caseId,
    required this.amount,
    required this.paidAt,
    required this.method,
    this.reference,
    this.note,
    this.recordedById,
    this.recordedByName,
    this.reversedAt,
    this.reversedById,
    this.reversalReason,
    this.createdAt,
  });

  final String id;
  final String caseId;
  final double amount;
  final DateTime paidAt;
  final PaymentMethod method;
  final String? reference;
  final String? note;
  final String? recordedById;

  /// Display name of who recorded the payment (PRD v2.0 payment record:
  /// `recorded_by`). Nullable — some endpoints return only the id.
  final String? recordedByName;
  final DateTime? reversedAt;
  final String? reversedById;
  final String? reversalReason;
  final DateTime? createdAt;

  bool get isReversed => reversedAt != null;

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id'] as String? ?? '',
      caseId: json['caseId'] as String? ?? '',
      // `amount` is a `numeric(12,2)` column, which Postgres hands back as
      // a *string* ("4000.00") — a strict `as num` cast threw "String is
      // not a subtype of num" and took the whole ledger view down with it.
      amount: _toAmount(json['amount']),
      paidAt:
          _toDate(json['paidAt']) ??
          _toDate(json['createdAt']) ??
          DateTime.now(),
      method: paymentMethodFromJson(json['method']),
      reference: json['reference'] as String?,
      note: json['note'] as String?,
      recordedById: json['recordedById'] as String?,
      recordedByName: json['recordedByName'] as String?,
      reversedAt: _toDate(json['reversedAt']),
      reversedById: json['reversedById'] as String?,
      reversalReason: json['reversalReason'] as String?,
      createdAt: _toDate(json['createdAt']),
    );
  }

  /// `numeric` columns arrive as JSON strings from this backend; a real
  /// JSON number is accepted too. Unparseable input degrades to 0 rather
  /// than throwing, so one bad row cannot blank the ledger.
  static double _toAmount(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  /// Accepts the ISO strings this backend serializes (`date` columns come
  /// back as `yyyy-MM-dd`, timestamps as full ISO) and an already-parsed
  /// `DateTime`. Returns null for absent/invalid values so callers can fall
  /// back to a related column instead of crashing.
  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    // `DateTime.tryParse` accepts both the date-only (`2026-08-20`) and
    // full-ISO forms this backend emits.
    return DateTime.tryParse(value.toString());
  }

  @override
  List<Object?> get props => [
    id,
    caseId,
    amount,
    paidAt,
    method,
    reference,
    note,
    recordedById,
    recordedByName,
    reversedAt,
    reversedById,
    reversalReason,
    createdAt,
  ];
}
