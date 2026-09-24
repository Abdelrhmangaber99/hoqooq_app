import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';

enum PaymentMethod {
  cash,
  bankTransfer,
  cheque,
  card,
  other;

  String toServerString() {
    switch (this) {
      case PaymentMethod.cash:
        return 'CASH';
      case PaymentMethod.bankTransfer:
        return 'BANK_TRANSFER';
      case PaymentMethod.cheque:
        return 'CHEQUE';
      case PaymentMethod.card:
        return 'CARD';
      case PaymentMethod.other:
        return 'OTHER';
    }
  }
}

PaymentMethod paymentMethodFromJson(dynamic value) {
  if (value is String) {
    switch (value.toUpperCase()) {
      case 'BANK_TRANSFER':
        return PaymentMethod.bankTransfer;
      case 'CHEQUE':
        return PaymentMethod.cheque;
      case 'CARD':
        return PaymentMethod.card;
      case 'OTHER':
        return PaymentMethod.other;
      case 'CASH':
      default:
        return PaymentMethod.cash;
    }
  }
  return PaymentMethod.cash;
}

String paymentMethodLabel(BuildContext context, PaymentMethod method) {
  switch (method) {
    case PaymentMethod.cash:
      return context.tr('cash');
    case PaymentMethod.bankTransfer:
      return context.tr('bank_transfer');
    case PaymentMethod.cheque:
      return context.tr('cheque');
    case PaymentMethod.card:
      return context.tr('card');
    case PaymentMethod.other:
      return context.tr('other');
  }
}
