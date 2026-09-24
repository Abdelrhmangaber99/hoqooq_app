import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../localization/app_localizations.dart';

/// Single formatting rule for every money amount the Finance UI renders
/// (PRD: "use the application's established money/currency formatting").
///
/// Formatting only — never parse user-entered amounts back through this;
/// form input stays a string until submission. Amounts are stored as
/// doubles rounded to 2dp at the entity boundary (`FinanceCalculator`
/// / `PaymentRecord.fromJson`), so a single `NumberFormat` render cannot
/// accumulate binary-fraction drift the way repeated arithmetic would.
String formatMoney(BuildContext context, double amount) {
  final formatter = NumberFormat.currency(
    locale: Localizations.localeOf(context).languageCode,
    symbol: context.tr('currency_sar'),
    decimalDigits: 2,
  );
  return formatter.format(amount);
}

/// `yyyy-MM-dd`, the wire/display date format used across the app's
/// finance screens and `CreatePaymentRequest`.
String formatPaymentDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
