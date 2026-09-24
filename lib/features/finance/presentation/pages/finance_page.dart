import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/auth/permission_check.dart';
import '../../../../core/auth/permission_codes.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_date_field.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../data/models/create_payment_request.dart';
import '../../domain/entities/case_finance_detail.dart';
import '../../domain/entities/case_finance_status.dart';
import '../../domain/entities/finance_summary.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_record.dart';

import '../bloc/case_ledger_bloc.dart';
import '../bloc/finance_summary_bloc.dart';
import '../bloc/payment_form_bloc.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  String _selectedTab = 'ALL';

  @override
  Widget build(BuildContext context) {
    if (!currentUserHasPerm(PermissionCodes.financeFirmRead)) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(context.tr('finance'))),
        body: Center(
          child: EmptyState(message: context.tr('no_finance_permission')),
        ),
      );
    }

    return BlocProvider(
      create: (context) =>
          getIt<FinanceSummaryBloc>()
            ..add(const FetchFinanceSummaryRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(context.tr('finance'))),
        body: SafeArea(
          child: BlocBuilder<FinanceSummaryBloc, FinanceSummaryState>(
            builder: (context, state) {
              if (state is FinanceSummaryLoading ||
                  state is FinanceSummaryInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              } else if (state is FinanceSummaryError) {
                return ErrorView(
                  message: state.message,
                  isForbidden: state.isForbidden,
                  onRetry: () => context.read<FinanceSummaryBloc>().add(
                    const FetchFinanceSummaryRequested(),
                  ),
                );
              } else if (state is FinanceSummaryLoaded) {
                return _buildContent(context, state.summary);
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, FinanceSummary summary) {
    final filteredCases = summary.cases.where((c) {
      if (_selectedTab == 'PAID') return c.status == CaseFinanceStatus.paid;
      if (_selectedTab == 'PARTIAL') {
        return c.status == CaseFinanceStatus.partial;
      }
      if (_selectedTab == 'UNPAID') {
        return c.status == CaseFinanceStatus.unpaid;
      }
      return true;
    }).toList();

    final currencySymbol = context.tr('currency_sar').trim();
    final currencyFmt = NumberFormat.currency(
      symbol: '$currencySymbol ',
      decimalDigits: 0,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary KPI Cards
          Row(
            children: [
              _buildKpiCard(
                context.tr('total_case_value'),
                currencyFmt.format(summary.totalCaseValue),
                AppColors.ink800,
                Icons.account_balance_wallet_outlined,
              ),
              const SizedBox(width: AppSpacing.s),
              _buildKpiCard(
                context.tr('total_collected'),
                currencyFmt.format(summary.totalCollected),
                AppColors.emerald500,
                Icons.check_circle_outline,
              ),
              const SizedBox(width: AppSpacing.s),
              _buildKpiCard(
                context.tr('total_outstanding'),
                currencyFmt.format(summary.totalOutstanding),
                AppColors.rust500,
                Icons.pending_actions_outlined,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),

          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTabChip(
                  'ALL',
                  '${context.tr('all')} (${summary.cases.length})',
                ),
                const SizedBox(width: 8),
                _buildTabChip(
                  'PAID',
                  '${context.tr('paid_in_full')} (${summary.paidCases})',
                ),
                const SizedBox(width: 8),
                _buildTabChip(
                  'PARTIAL',
                  '${context.tr('partially_paid')} (${summary.partialCases})',
                ),
                const SizedBox(width: 8),
                _buildTabChip(
                  'UNPAID',
                  '${context.tr('unpaid')} (${summary.unpaidCases})',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),

          // Case List
          if (filteredCases.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: EmptyState(
                message: context.tr('no_cases_matching_filter'),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredCases.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s),
              itemBuilder: (context, index) {
                final item = filteredCases[index];
                return _buildCaseFinanceTile(context, item, currencyFmt);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.medium,
              border: Border.all(color: AppColors.paperLine),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: constraints.maxWidth,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      value,
                      maxLines: 1,
                      style: AppTypography.h3.copyWith(
                        color: color,
                        fontFamily: AppTypography.monoFont,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabChip(String value, String label) {
    final isSelected = _selectedTab == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.brass500,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (_) => setState(() => _selectedTab = value),
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

  Widget _buildCaseFinanceTile(
    BuildContext context,
    CaseFinanceSummaryRow item,
    NumberFormat fmt,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.paperLine),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Flexible(
              child: Text(
                '${context.tr('case_number_prefix')}${item.caseNumber}',
                overflow: TextOverflow.ellipsis,
                style: AppTypography.h3,
              ),
            ),
            const Spacer(),
            AppBadge(
              label: caseFinanceStatusLabel(context, item.status),
              variant: _statusBadgeVariant(item.status),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          // Wrap, not a fixed Row: three label+amount pairs overflowed
          // horizontally on narrow screens and in Arabic (long labels +
          // mono digits). Wrapping lets the figures stack instead.
          child: Wrap(
            spacing: AppSpacing.l,
            runSpacing: AppSpacing.xs,
            children: [
              _buildAmountLine(
                context.tr('agreed_fee'),
                fmt.format(item.agreedFee),
                AppColors.textPrimary,
              ),
              _buildAmountLine(
                context.tr('total_collected'),
                fmt.format(item.paid),
                AppColors.emerald500,
              ),
              _buildAmountLine(
                context.tr('remaining'),
                fmt.format(item.remaining),
                AppColors.rust500,
              ),
            ],
          ),
        ),
        onTap: () => _showCaseLedgerBottomSheet(context, item.caseId),
      ),
    );
  }

  Widget _buildAmountLine(String label, String value, Color color) {
    return Text(
      '$label: $value',
      style: AppTypography.bodySmall.copyWith(
        color: color,
        fontFamily: AppTypography.monoFont,
      ),
    );
  }

  void _showCaseLedgerBottomSheet(BuildContext context, String caseId) {
    final parentContext = context;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  getIt<CaseLedgerBloc>()
                    ..add(FetchCaseLedgerRequested(caseId)),
            ),
            BlocProvider(create: (_) => getIt<PaymentFormBloc>()),
          ],
          child: _CaseLedgerSheetContent(
            caseId: caseId,
            onRefreshParent: () {
              parentContext.read<FinanceSummaryBloc>().add(
                const FetchFinanceSummaryRequested(),
              );
            },
          ),
        );
      },
    );
  }
}

class _CaseLedgerSheetContent extends StatefulWidget {
  const _CaseLedgerSheetContent({
    required this.caseId,
    required this.onRefreshParent,
  });

  final String caseId;
  final VoidCallback onRefreshParent;

  @override
  State<_CaseLedgerSheetContent> createState() =>
      _CaseLedgerSheetContentState();
}

class _CaseLedgerSheetContentState extends State<_CaseLedgerSheetContent> {
  bool _showRecordPaymentForm = false;
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _paidAt = DateTime.now();
  PaymentMethod _method = PaymentMethod.cash;

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = context.tr('currency_sar').trim();
    final currencyFmt = NumberFormat.currency(
      symbol: '$currencySymbol ',
      decimalDigits: 0,
    );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return BlocListener<PaymentFormBloc, PaymentFormState>(
          listener: (context, state) {
            if (state is PaymentFormSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.tr('payment_recorded_successfully')),
                ),
              );
              setState(() => _showRecordPaymentForm = false);
              _amountController.clear();
              _referenceController.clear();
              _noteController.clear();
              context.read<CaseLedgerBloc>().add(
                FetchCaseLedgerRequested(widget.caseId),
              );
              widget.onRefreshParent();
            } else if (state is PaymentFormError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.ink200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                Text(
                  context.tr('account_details_and_ledger'),
                  style: AppTypography.h3,
                ),
                const SizedBox(height: AppSpacing.m),
                Expanded(
                  child: BlocBuilder<CaseLedgerBloc, CaseLedgerState>(
                    builder: (context, state) {
                      if (state is CaseLedgerLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      } else if (state is CaseLedgerError) {
                        return ErrorView(
                          message: state.message,
                          isForbidden: state.isForbidden,
                          onRetry: () => context.read<CaseLedgerBloc>().add(
                            FetchCaseLedgerRequested(widget.caseId),
                          ),
                        );
                      } else if (state is CaseLedgerLoaded) {
                        return _buildLedgerView(
                          context,
                          state.detail,
                          currencyFmt,
                          scrollController,
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLedgerView(
    BuildContext context,
    CaseFinanceDetail detail,
    NumberFormat fmt,
    ScrollController scrollController,
  ) {
    return ListView(
      controller: scrollController,
      children: [
        // Fee Summary Box
        Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: AppColors.paperSoft,
            borderRadius: AppRadius.medium,
            border: Border.all(color: AppColors.paperLine),
          ),
          // Wrap, not Row(spaceAround): three unconstrained Columns
          // overflowed on narrow screens / Arabic labels.
          child: Wrap(
            spacing: AppSpacing.l,
            runSpacing: AppSpacing.m,
            alignment: WrapAlignment.spaceAround,
            children: [
              _buildMetricItem(
                context.tr('agreed_fee'),
                detail.agreedFee != null ? fmt.format(detail.agreedFee!) : '—',
                AppColors.textPrimary,
              ),
              _buildMetricItem(
                context.tr('total_paid'),
                fmt.format(detail.paid),
                AppColors.emerald500,
              ),
              _buildMetricItem(
                context.tr('remaining'),
                detail.remaining != null ? fmt.format(detail.remaining!) : '—',
                AppColors.rust500,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.l),

        // Record Payment Form Toggle Button
        if (currentUserHasPerm(PermissionCodes.financePaymentRecord) &&
            (detail.remaining ?? 0) > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            child: AppButton(
              text: _showRecordPaymentForm
                  ? context.tr('cancel_payment_recording')
                  : context.tr('record_new_payment'),
              style: _showRecordPaymentForm
                  ? AppButtonStyle.secondary
                  : AppButtonStyle.primary,
              onPressed: () {
                setState(
                  () => _showRecordPaymentForm = !_showRecordPaymentForm,
                );
              },
            ),
          ),

        if (_showRecordPaymentForm) _buildPaymentForm(context, detail),

        const SizedBox(height: AppSpacing.m),
        Text(context.tr('payment_records_history'), style: AppTypography.h3),
        const SizedBox(height: AppSpacing.s),

        if (detail.payments.isEmpty)
          EmptyState(message: context.tr('no_payments_recorded_for_case'))
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: detail.payments.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
            itemBuilder: (context, index) {
              final payment = detail.payments[index];
              return _buildPaymentRecordTile(context, payment, fmt);
            },
          ),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTypography.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          softWrap: true,
          style: AppTypography.h3.copyWith(
            color: color,
            fontFamily: AppTypography.monoFont,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentForm(BuildContext context, CaseFinanceDetail detail) {
    final formState = context.watch<PaymentFormBloc>().state;
    final isSubmitting = formState is PaymentFormSubmitting;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.brass400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('add_payment'), style: AppTypography.h3),
          const SizedBox(height: AppSpacing.m),
          AppTextField(
            label:
                '${context.tr('amount')} (${context.tr('currency_sar').trim()})',
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: AppSpacing.m),
          AppDateField(
            label: context.tr('payment_date'),
            value: _paidAt,
            dateFormat: DateFormat('yyyy-MM-dd'),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _paidAt,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) setState(() => _paidAt = picked);
            },
          ),
          const SizedBox(height: AppSpacing.m),
          AppDropdownField<PaymentMethod>(
            label: context.tr('method'),
            value: _method,
            items: PaymentMethod.values,
            labelOf: (m) => paymentMethodLabel(context, m),
            onChanged: (val) {
              if (val != null) setState(() => _method = val);
            },
          ),
          const SizedBox(height: AppSpacing.m),
          AppTextField(
            label: context.tr('reference_optional'),
            controller: _referenceController,
          ),
          const SizedBox(height: AppSpacing.m),
          AppTextField(
            label: context.tr('note_optional'),
            controller: _noteController,
          ),
          const SizedBox(height: AppSpacing.l),
          AppButton(
            text: context.tr('save_payment'),
            isLoading: isSubmitting,
            onPressed: () {
              final amountStr = _amountController.text.trim();
              final amount = double.tryParse(amountStr);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('enter_valid_amount'))),
                );
                return;
              }
              final paidAtStr = DateFormat('yyyy-MM-dd').format(_paidAt);
              context.read<PaymentFormBloc>().add(
                RecordPaymentSubmitted(
                  caseId: widget.caseId,
                  request: CreatePaymentRequest(
                    amount: amount,
                    paidAt: paidAtStr,
                    method: _method,
                    reference: _referenceController.text.trim(),
                    note: _noteController.text.trim(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRecordTile(
    BuildContext context,
    PaymentRecord payment,
    NumberFormat fmt,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: payment.isReversed
            ? AppColors.rust100.withValues(alpha: 0.3)
            : AppColors.surface,
        borderRadius: AppRadius.small,
        border: Border.all(
          color: payment.isReversed ? AppColors.rust100 : AppColors.paperLine,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Flexible on both text ends: a long amount or date plus the
              // method badge overflowed the fixed-width spacer on narrow
              // screens and in Arabic.
              Flexible(
                child: Text(
                  fmt.format(payment.amount),
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.h3.copyWith(
                    decoration: payment.isReversed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: payment.isReversed
                        ? AppColors.textHint
                        : AppColors.emerald500,
                    fontFamily: AppTypography.monoFont,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AppBadge(
                label: paymentMethodLabel(context, payment.method),
                variant: AppBadgeVariant.neutral,
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  DateFormat('yyyy/MM/dd').format(payment.paidAt),
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    fontFamily: AppTypography.monoFont,
                  ),
                ),
              ),
            ],
          ),
          if (payment.reference != null && payment.reference!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${context.tr('reference_number')}: ${payment.reference}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
          if (payment.note != null && payment.note!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              '${context.tr('description')}: ${payment.note}',
              style: AppTypography.bodySmall,
            ),
          ],
          if (payment.isReversed) ...[
            const SizedBox(height: 4),
            Text(
              '${context.tr('cancelled')}: ${payment.reversalReason ?? context.tr('default_reversal_reason')}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.rust500,
                fontWeight: FontWeight.bold,
              ),
            ),
          ] else if (currentUserHasPerm(PermissionCodes.financeManage)) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(
                  Icons.undo,
                  size: 14,
                  color: AppColors.rust500,
                ),
                label: Text(
                  context.tr('reverse_payment'),
                  style: const TextStyle(
                    color: AppColors.rust500,
                    fontSize: 12,
                  ),
                ),
                onPressed: () => _showReverseDialog(context, payment.id),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showReverseDialog(BuildContext context, String paymentId) {
    final reasonController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(context.tr('reverse_financial_operation')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.tr('reverse_payment_confirm_message')),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: context.tr('reversal_reason'),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rust500),
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) return;
              Navigator.pop(dialogCtx);
              context.read<PaymentFormBloc>().add(
                ReversePaymentSubmitted(paymentId: paymentId, reason: reason),
              );
            },
            child: Text(
              context.tr('confirm_cancellation'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
