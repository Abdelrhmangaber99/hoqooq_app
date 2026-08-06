import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/entities/invoice_status.dart';
import '../domain/entities/payment_method.dart';
import '../domain/entities/payment_status.dart';

String invoiceStatusLabel(BuildContext context, InvoiceStatus status) {
  switch (status) {
    case InvoiceStatus.draft:
      return context.tr('draft');
    case InvoiceStatus.sent:
      return context.tr('sent');
    case InvoiceStatus.partial:
      return context.tr('partial');
    case InvoiceStatus.paid:
      return context.tr('paid');
    case InvoiceStatus.cancelled:
      return context.tr('cancelled');
    case InvoiceStatus.unknown:
      return context.tr('unknown');
  }
}

Color invoiceStatusColor(InvoiceStatus status) {
  switch (status) {
    case InvoiceStatus.draft:
      return AppColors.textHint;
    case InvoiceStatus.sent:
      return AppColors.info;
    case InvoiceStatus.partial:
      return AppColors.warning;
    case InvoiceStatus.paid:
      return AppColors.success;
    case InvoiceStatus.cancelled:
      return AppColors.textSecondary;
    case InvoiceStatus.unknown:
      return AppColors.textHint;
  }
}

String paymentMethodLabel(BuildContext context, PaymentMethod method) {
  switch (method) {
    case PaymentMethod.cash:
      return context.tr('cash');
    case PaymentMethod.bankTransfer:
      return context.tr('bank_transfer');
    case PaymentMethod.cheque:
      return context.tr('cheque');
    case PaymentMethod.online:
      return context.tr('online');
    case PaymentMethod.unknown:
      return context.tr('unknown');
  }
}

String paymentStatusLabel(BuildContext context, PaymentStatus status) {
  switch (status) {
    case PaymentStatus.paid:
      return context.tr('paid');
    case PaymentStatus.partial:
      return context.tr('partial');
    case PaymentStatus.unpaid:
      return context.tr('unpaid');
    case PaymentStatus.noInvoice:
      return context.tr('no_invoice');
    case PaymentStatus.unknown:
      return context.tr('unknown');
  }
}

Color paymentStatusColor(PaymentStatus status) {
  switch (status) {
    case PaymentStatus.paid:
      return AppColors.success;
    case PaymentStatus.partial:
      return AppColors.warning;
    case PaymentStatus.unpaid:
      return AppColors.error;
    case PaymentStatus.noInvoice:
      return AppColors.textHint;
    case PaymentStatus.unknown:
      return AppColors.textHint;
  }
}
