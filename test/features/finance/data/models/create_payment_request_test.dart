import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/finance/data/models/create_payment_request.dart';
import 'package:hqooq/features/finance/domain/entities/payment_method.dart';

void main() {
  group('CreatePaymentRequest', () {
    test('serializes required fields and trims reference and note', () {
      const request = CreatePaymentRequest(
        amount: 2500.0,
        paidAt: '2026-09-22',
        method: PaymentMethod.bankTransfer,
        reference: '  REF-998877  ',
        note: '  Advance payment for court fees  ',
      );

      final json = request.toJson();

      expect(json['amount'], 2500.0);
      expect(json['paidAt'], '2026-09-22');
      expect(json['method'], 'BANK_TRANSFER');
      expect(json['reference'], 'REF-998877');
      expect(json['note'], 'Advance payment for court fees');
    });

    test('omits reference and note when null or empty/whitespace', () {
      const request = CreatePaymentRequest(
        amount: 1000.0,
        paidAt: '2026-09-22',
        method: PaymentMethod.cash,
        reference: '   ',
        note: '',
      );

      final json = request.toJson();

      expect(json['amount'], 1000.0);
      expect(json['method'], 'CASH');
      expect(json.containsKey('reference'), isFalse);
      expect(json.containsKey('note'), isFalse);
    });
  });
}
