import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/permission_check.dart';
import '../../../../core/auth/permission_codes.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/error_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_date_field.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../data/models/create_payment_request.dart';
import '../../domain/entities/case_finance_detail.dart';
import '../../domain/entities/case_finance_status.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_record.dart';
import '../bloc/case_ledger_bloc.dart';
import '../bloc/payment_form_bloc.dart';

/// The Case Details "Finance" tab (PRD v2.0 §6.2.11 case finance view).
///
/// Rendered only when the session holds `finance.case.view` — the blocs are
/// not even created otherwise (see CaseDetailsPage), so no finance API call
/// is made without effective permission (BR-028). Inside the tab,
/// `finance.payment.record` gates the record-payment action and
/// `finance.manage` gates payment reversal. The agreed fee is a Case field
/// (edited on the Case form under `case.edit`) and is read-only here.
class CaseFinanceTab extends StatelessWidget {
  const CaseFinanceTab({super.key, required this.caseId});

  final String caseId;

  @override
  Widget build(BuildContext context) {
    return _CaseFinanceTabView(caseId: caseId);
  }
}

class _CaseFinanceTabView extends StatelessWidget {
  const _CaseFinanceTabView({required this.caseId});

  final String caseId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentFormBloc, PaymentFormState>(
      listener: (context, state) {
        if (state is PaymentFormSuccess) {
          // Refresh the ledger in place — totals and history recompute from
          // the fresh payment records; no full app reload (PRD payment
          // workflow step 5).
          context.read<CaseLedgerBloc>().add(FetchCaseLedgerRequested(caseId));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('payment_recorded_successfully')),
            ),
          );
        }
      },
      child: BlocBuilder<CaseLedgerBloc, CaseLedgerState>(
        builder: (context, state) {
          if (state is CaseLedgerLoading || state is CaseLedgerInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is CaseLedgerError && state.detail == null) {
            return ErrorView(
              message: state.message,
              isForbidden: state.isForbidden,
              onRetry: () => context.read<CaseLedgerBloc>().add(
                FetchCaseLedgerRequested(caseId),
              ),
            );
          }
          final detail = state is CaseLedgerLoaded
              ? state.detail
              : (state as CaseLedgerError).detail!;
          final isError = state is CaseLedgerError;
          return Column(
            children: [
              // Refresh failed but a previously loaded ledger still
              // exists — keep rendering it with the failure shown
              // above, and offer retry unless forbidden.
              if (isError)
                Material(
                  color: AppColors.rust100,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                      vertical: AppSpacing.s,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 18,
                          color: AppColors.rust500,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.message,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.rust600,
                            ),
                          ),
                        ),
                        if (!state.isForbidden)
                          TextButton(
                            onPressed: () => context.read<CaseLedgerBloc>().add(
                              FetchCaseLedgerRequested(caseId),
                            ),
                            child: Text(context.tr('retry')),
                          ),
                      ],
                    ),
                  ),
                ),
              Expanded(child: _financeContent(context, detail)),
            ],
          );
        },
      ),
    );
  }

  Widget _financeContent(BuildContext context, CaseFinanceDetail detail) {
    // A payment can only be recorded once an agreed fee exists: the server
    // rejects payment creation with `Set the Case agreed fee before
    // recording payments` while `agreed_fee` is NULL. The fee itself is a
    // Case field edited on the Case form, so this tab never offers to
    // write it — it explains what to do instead of opening a form that
    // could only ever 404.
    final hasAgreedFee = detail.agreedFee != null;
    final canRecordPayment =
        currentUserHasPerm(PermissionCodes.financePaymentRecord) &&
        hasAgreedFee &&
        (detail.remaining ?? 0) > 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (detail.agreedFee == null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppBadge(
                label: context.tr('agreed_fee_not_set'),
                variant: AppBadgeVariant.neutral,
                icon: Icons.help_outline_rounded,
              ),
            )
          else
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppBadge(
                label: caseFinanceStatusLabel(context, detail.status),
                variant: _statusBadgeVariant(detail.status),
              ),
            ),
          const SizedBox(height: AppSpacing.m),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth >= 720
                  ? (constraints.maxWidth - AppSpacing.m * 2) / 3
                  : constraints.maxWidth;
              return Wrap(
                spacing: AppSpacing.m,
                runSpacing: AppSpacing.m,
                children: [
                  _FinanceMetricCard(
                    width: width,
                    label: context.tr('agreed_fee'),
                    value: detail.agreedFee != null
                        ? formatMoney(context, detail.agreedFee!)
                        : '—',
                    color: AppColors.ink800,
                  ),
                  _FinanceMetricCard(
                    width: width,
                    label: context.tr('paid'),
                    value: formatMoney(context, detail.paid),
                    color: AppColors.emerald500,
                  ),
                  _FinanceMetricCard(
                    width: width,
                    label: context.tr('remaining'),
                    value: detail.remaining != null
                        ? formatMoney(context, detail.remaining!)
                        : '—',
                    color: AppColors.rust500,
                  ),
                ],
              );
            },
          ),
          if (!hasAgreedFee) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              context.tr('agreed_fee_not_set_hint'),
              style: AppTypography.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.m),
          if (canRecordPayment)
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              alignment: WrapAlignment.end,
              children: [
                FilledButton.icon(
                  onPressed: () => _showRecordPaymentDialog(context),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    context.tr(
                      detail.payments.isEmpty
                          ? 'record_first_payment'
                          : 'record_payment',
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.l),
          Text(context.tr('payment_history'), style: AppTypography.h3),
          const SizedBox(height: AppSpacing.m),
          if (detail.payments.isEmpty)
            EmptyState(
              message: context.tr('no_payments_recorded_for_case'),
              icon: Icons.receipt_long_outlined,
            )
          else
            _PaymentHistoryCard(payments: detail.payments),
        ],
      ),
    );
  }

  AppBadgeVariant _statusBadgeVariant(CaseFinanceStatus status) {
    switch (status) {
      case CaseFinanceStatus.paid:
        return AppBadgeVariant.success;
      case CaseFinanceStatus.partial:
        return AppBadgeVariant.warning;
      case CaseFinanceStatus.unpaid:
        return AppBadgeVariant.danger;
    }
  }

  Future<void> _showRecordPaymentDialog(BuildContext context) async {
    final paymentBloc = context.read<PaymentFormBloc>();
    // Snapshot the overpayment cap at open time — dialogs render on the
    // root overlay, outside this subtree's bloc providers.
    final ledgerState = context.read<CaseLedgerBloc>().state;
    final detail = ledgerState is CaseLedgerLoaded ? ledgerState.detail : null;
    final remainingMinor = detail?.agreedFee == null
        ? null
        : ((detail!.remaining ?? 0) * 100).round();
    await showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: paymentBloc,
        child: _RecordPaymentDialog(
          caseId: caseId,
          remainingMinor: remainingMinor,
        ),
      ),
    );
  }
}

/// One of the Agreed Fee / Paid / Remaining cards. Width is driven by the
/// parent LayoutBuilder so three cards share wide screens and stack on
/// narrow ones — same responsive rule as the tab's previous inline version.
class _FinanceMetricCard extends StatelessWidget {
  const _FinanceMetricCard({
    required this.width,
    required this.label,
    required this.value,
    required this.color,
  });

  final double width;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.paperLine),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.bodySmall),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.h3.copyWith(
                color: color,
                fontFamily: AppTypography.monoFont,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentHistoryCard extends StatelessWidget {
  const _PaymentHistoryCard({required this.payments});

  final List<PaymentRecord> payments;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.paperLine),
      ),
      child: Column(
        children: [
          for (var index = 0; index < payments.length; index++) ...[
            if (index > 0) const Divider(height: 1),
            _PaymentHistoryRow(payment: payments[index]),
          ],
        ],
      ),
    );
  }
}

/// One payment record with every PRD field: amount, date, method,
/// reference, notes, recorder — plus reversal state.
class _PaymentHistoryRow extends StatelessWidget {
  const _PaymentHistoryRow({required this.payment});

  final PaymentRecord payment;

  @override
  Widget build(BuildContext context) {
    final hasReference = payment.reference?.trim().isNotEmpty ?? false;
    final hasNotes = payment.note?.trim().isNotEmpty ?? false;
    final canReverse =
        currentUserHasPerm(PermissionCodes.financeManage) &&
        !payment.isReversed;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        formatMoney(context, payment.amount),
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium.copyWith(
                          fontFamily: AppTypography.monoFont,
                          fontWeight: FontWeight.w600,
                          decoration: payment.isReversed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppBadge(
                      label: paymentMethodLabel(context, payment.method),
                      variant: AppBadgeVariant.neutral,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: AppSpacing.m,
                  runSpacing: 4,
                  children: [
                    _FinanceInfoRow(
                      label: context.tr('payment_date'),
                      value: formatPaymentDate(payment.paidAt),
                    ),
                    if (hasReference)
                      _FinanceInfoRow(
                        label: context.tr('reference_number'),
                        value: payment.reference!.trim(),
                      ),
                    if (hasNotes)
                      _FinanceInfoRow(
                        label: context.tr('notes'),
                        value: payment.note!.trim(),
                      ),
                    if (payment.recordedByName != null)
                      _FinanceInfoRow(
                        label: context.tr('recorded_by'),
                        value: payment.recordedByName!,
                      ),
                  ],
                ),
                if (payment.isReversed) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${context.tr('cancelled')}: ${payment.reversalReason ?? context.tr('default_reversal_reason')}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.rust500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (canReverse)
            TextButton(
              onPressed: () => _showReverseDialog(context),
              child: Text(
                context.tr('reverse_payment'),
                style: const TextStyle(color: AppColors.rust500),
              ),
            ),
        ],
      ),
    );
  }

  void _showReverseDialog(BuildContext context) {
    final paymentBloc = context.read<PaymentFormBloc>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: paymentBloc,
        child: _ReversePaymentDialog(paymentId: payment.id),
      ),
    );
  }
}

class _FinanceInfoRow extends StatelessWidget {
  const _FinanceInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: $value',
      style: AppTypography.bodySmall.copyWith(color: AppColors.ink600),
    );
  }
}

/// Integer minor-unit (piastre-style) parsing for amount inputs. The UI
/// never does floating-point arithmetic on money (PRD money rule): the
/// user's text is validated here in integers, and converted to the wire's
/// 2dp decimal only at the entity boundary.
class _AmountInput {
  _AmountInput._();

  static final _amountPattern = RegExp(r'^\d{1,9}([.,]\d{1,2})?$');

  /// Accepts `1200`, `1200.5`, `1200,25` and Arabic-Indic digits
  /// (`١٢٠٠٫٥٠`); rejects negative, scientific, >2dp and 0.
  static int? parseToMinor(String input) {
    final text = _normalizeDigits(input.trim());
    if (!_amountPattern.hasMatch(text)) return null;
    final parts = text.split(RegExp(r'[.,]'));
    final whole = int.parse(parts[0]);
    final fraction = parts.length > 1
        ? int.parse(parts[1].padRight(2, '0'))
        : 0;
    final minor = whole * 100 + fraction;
    if (minor <= 0) return null;
    return minor;
  }

  /// Minor units → `major.minor` string, parseable without float error at
  /// 2dp magnitude.
  static String minorToString(int minor) =>
      '${minor ~/ 100}.${(minor % 100).toString().padLeft(2, '0')}';

  static String _normalizeDigits(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      // U+0660..U+0669 → 0..9 so Arabic-keyboard users aren't rejected.
      if (rune >= 0x0660 && rune <= 0x0669) {
        buffer.write(rune - 0x0660);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }
}

class _RecordPaymentDialog extends StatefulWidget {
  const _RecordPaymentDialog({required this.caseId, this.remainingMinor});

  final String caseId;

  /// Overpayment cap in minor units (integer), snapshotted when the dialog
  /// opens. Null when the case has no agreed fee — nothing to cap against.
  final int? remainingMinor;

  @override
  State<_RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends State<_RecordPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _amountFocus = FocusNode();
  final amountController = TextEditingController();
  final referenceController = TextEditingController();
  final notesController = TextEditingController();
  PaymentMethod method = PaymentMethod.cash;
  DateTime paidAt = DateTime.now();

  @override
  void dispose() {
    amountController.dispose();
    referenceController.dispose();
    notesController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  /// Required amount, positive, well-formed (2dp max) — and never more
  /// than the remaining balance when a fee is set (PRD overpayment rule;
  /// the server re-validates, this is UX-level guard).
  String? _validateAmount(String? value) {
    final minor = _AmountInput.parseToMinor(value ?? '');
    if (minor == null) return context.tr('enter_valid_amount');
    final cap = widget.remainingMinor;
    if (cap != null && minor > cap) {
      return context.tr('payment_exceeds_remaining');
    }
    return null;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final minor = _AmountInput.parseToMinor(amountController.text)!;
    final request = CreatePaymentRequest(
      amount: double.parse(_AmountInput.minorToString(minor)),
      paidAt: formatPaymentDate(paidAt),
      method: method,
      reference: referenceController.text.trim(),
      note: notesController.text.trim(),
    );
    context.read<PaymentFormBloc>().add(
      RecordPaymentSubmitted(caseId: widget.caseId, request: request),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentFormBloc, PaymentFormState>(
      listener: (context, state) {
        if (state is PaymentFormSuccess) {
          // Success closes the dialog; the tab-level listener refreshes
          // the ledger and shows the standard success feedback.
          Navigator.of(context).pop();
        } else if (state is PaymentFormError) {
          // Forbidden means finance rights vanished mid-form — retrying
          // would 403 again, so close instead. Other failures keep the
          // entered data on screen for correction.
          if (state.isForbidden) {
            Navigator.of(context).pop();
            return;
          }
          context.showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) {
        final submitting = state is PaymentFormSubmitting;
        return AlertDialog(
          title: Text(context.tr('record_payment')),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    controller: amountController,
                    focusNode: _amountFocus,
                    label: context.tr('amount'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d٠-٩.,]')),
                    ],
                    validator: _validateAmount,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppDateField(
                    label: context.tr('payment_date'),
                    value: paidAt,
                    dateFormat: DateFormat('yyyy-MM-dd'),
                    onTap: () async {
                      final selected = await showDatePicker(
                        context: context,
                        initialDate: paidAt,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (selected != null) setState(() => paidAt = selected);
                    },
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppDropdownField<PaymentMethod>(
                    label: context.tr('method'),
                    value: method,
                    items: PaymentMethod.values,
                    labelOf: (value) => paymentMethodLabel(context, value),
                    onChanged: (value) {
                      if (value != null) setState(() => method = value);
                    },
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppTextField(
                    controller: referenceController,
                    label: context.tr('reference_optional'),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppTextField(
                    controller: notesController,
                    label: context.tr('notes'),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.pop(context),
              child: Text(context.tr('cancel')),
            ),
            FilledButton(
              onPressed: submitting ? null : _submit,
              child: submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(context.tr('confirm')),
            ),
          ],
        );
      },
    );
  }
}

/// finance.manage: reverse a payment, keeping its record. There is no
/// client-side agreed-fee editor — the Case Finance API has no fee route,
/// so the fee is written on the Case form and this tab only displays it.
class _ReversePaymentDialog extends StatefulWidget {
  const _ReversePaymentDialog({required this.paymentId});

  final String paymentId;

  @override
  State<_ReversePaymentDialog> createState() => _ReversePaymentDialogState();
}

class _ReversePaymentDialogState extends State<_ReversePaymentDialog> {
  final reasonController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentFormBloc, PaymentFormState>(
      listener: (context, state) {
        if (_submitted && state is PaymentFormSuccess) {
          Navigator.of(context).pop();
        } else if (state is PaymentFormError) {
          _submitted = false;
          if (state.isForbidden) {
            Navigator.of(context).pop();
            return;
          }
          context.showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) {
        final submitting = state is PaymentFormSubmitting;
        return AlertDialog(
          title: Text(context.tr('reverse_payment')),
          content: AppTextField(
            controller: reasonController,
            label: context.tr('reversal_reason'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.pop(context),
              child: Text(context.tr('cancel')),
            ),
            FilledButton(
              onPressed: submitting
                  ? null
                  : () {
                      final reason = reasonController.text.trim();
                      if (reason.length < 3) return;
                      _submitted = true;
                      context.read<PaymentFormBloc>().add(
                        ReversePaymentSubmitted(
                          paymentId: widget.paymentId,
                          reason: reason,
                        ),
                      );
                    },
              child: Text(context.tr('confirm')),
            ),
          ],
        );
      },
    );
  }
}
