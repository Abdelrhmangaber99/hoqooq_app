import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_method.dart';

class CreatePaymentRequest extends Equatable {
  const CreatePaymentRequest({
    required this.amount,
    required this.paidAt,
    required this.method,
    this.reference,
    this.note,
  });

  final double amount;
  final String paidAt; // YYYY-MM-DD
  final PaymentMethod method;
  final String? reference;
  final String? note;

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'paidAt': paidAt,
      'method': method.toServerString(),
      if (reference != null && reference!.trim().isNotEmpty)
        'reference': reference!.trim(),
      if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
    };
  }

  @override
  List<Object?> get props => [amount, paidAt, method, reference, note];
}
