import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

enum CaseFinanceStatus {
  paid,
  partial,
  unpaid;
}

CaseFinanceStatus caseFinanceStatusFromJson(dynamic value) {
  if (value is String) {
    switch (value.toUpperCase()) {
      case 'PAID':
        return CaseFinanceStatus.paid;
      case 'PARTIAL':
        return CaseFinanceStatus.partial;
      case 'UNPAID':
      default:
        return CaseFinanceStatus.unpaid;
    }
  }
  return CaseFinanceStatus.unpaid;
}

/// Localized status labels resolved via the app's `context.tr()` JSON
/// system (same convention as `paymentMethodLabel`).
String caseFinanceStatusLabel(BuildContext context, CaseFinanceStatus status) {
  switch (status) {
    case CaseFinanceStatus.paid:
      return context.tr('paid_in_full');
    case CaseFinanceStatus.partial:
      return context.tr('partially_paid');
    case CaseFinanceStatus.unpaid:
      return context.tr('unpaid');
  }
}

Color caseFinanceStatusColor(CaseFinanceStatus status) {
  switch (status) {
    case CaseFinanceStatus.paid:
      return AppColors.emerald500;
    case CaseFinanceStatus.partial:
      return AppColors.brass500;
    case CaseFinanceStatus.unpaid:
      return AppColors.rust500;
  }
}

Color caseFinanceStatusBackgroundColor(CaseFinanceStatus status) {
  switch (status) {
    case CaseFinanceStatus.paid:
      return AppColors.emerald100;
    case CaseFinanceStatus.partial:
      return AppColors.brass100;
    case CaseFinanceStatus.unpaid:
      return AppColors.rust100;
  }
}
