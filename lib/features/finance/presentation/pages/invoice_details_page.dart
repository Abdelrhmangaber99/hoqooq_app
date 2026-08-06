import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/auth/permission_check.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_date_field.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../data/models/create_payment_request.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_method.dart';
import '../bloc/invoice_details_bloc.dart';
import '../bloc/payment_form_bloc.dart';
import '../finance_display_helpers.dart';

class InvoiceDetailsPage extends StatelessWidget {
  final String invoiceId;

  const InvoiceDetailsPage({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<InvoiceDetailsBloc>()
            ..add(FetchInvoiceDetailsRequested(invoiceId)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(context.tr('invoice'))),
        body: SafeArea(
          child: BlocBuilder<InvoiceDetailsBloc, InvoiceDetailsState>(
            builder: (context, state) {
              if (state is InvoiceDetailsLoading ||
                  state is InvoiceDetailsInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              } else if (state is InvoiceDetailsError) {
                return ErrorView(
                  message: state.message,
                  isForbidden: state.isForbidden,
                  onRetry: () => context.read<InvoiceDetailsBloc>().add(
                    FetchInvoiceDetailsRequested(invoiceId),
                  ),
                );
              } else if (state is InvoiceDetailsLoaded) {
                return _buildContent(context, state.invoice);
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Invoice invoice) {
    final dateFormat = DateFormat.yMMMd();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(invoice.invoiceNumber, style: AppTypography.h2),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: invoiceStatusColor(
                    invoice.status,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  invoiceStatusLabel(context, invoice.status),
                  style: TextStyle(
                    color: invoiceStatusColor(invoice.status),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          if (currentUserHasPerm('finance.update')) ...[
            const SizedBox(height: AppSpacing.m),
            AppButton(
              text: context.tr('edit_invoice'),
              style: AppButtonStyle.outline,
              onPressed: () async {
                final updated = await context.push<bool>(
                  '${AppRouter.finance}/${invoice.id}/edit',
                  extra: invoice,
                );
                if (updated == true && context.mounted) {
                  context.read<InvoiceDetailsBloc>().add(
                    FetchInvoiceDetailsRequested(invoiceId),
                  );
                }
              },
            ),
          ],
          const SizedBox(height: AppSpacing.l),
          _buildOverview(context, invoice, dateFormat),
          const SizedBox(height: AppSpacing.l),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.tr('payments'), style: AppTypography.h3),
              if (currentUserHasPerm('finance.create'))
                GestureDetector(
                  onTap: () => _showRecordPaymentSheet(context, invoice.id),
                  child: const Icon(
                    Icons.add_circle_outline,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          _buildPaymentsList(context, invoice.payments ?? const []),
        ],
      ),
    );
  }

  Widget _buildOverview(
    BuildContext context,
    Invoice invoice,
    DateFormat dateFormat,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewRow(
            context.tr('client'),
            invoice.client?.fullName ?? context.tr('unknown'),
          ),
          if (invoice.caseSummary != null)
            _buildOverviewRow(
              context.tr('case'),
              invoice.caseSummary!.caseNumber,
            ),
          _buildOverviewRow(
            context.tr('issue_date'),
            dateFormat.format(invoice.issueDate),
          ),
          _buildOverviewRow(
            context.tr('due_date'),
            dateFormat.format(invoice.dueDate),
          ),
          _buildOverviewRow(
            context.tr('subtotal'),
            invoice.subtotal.toStringAsFixed(2),
          ),
          _buildOverviewRow(
            context.tr('tax_total'),
            invoice.taxTotal.toStringAsFixed(2),
          ),
          _buildOverviewRow(
            context.tr('grand_total'),
            invoice.grandTotal.toStringAsFixed(2),
          ),
          if (invoice.notes != null && invoice.notes!.isNotEmpty)
            _buildOverviewRow(context.tr('notes'), invoice.notes!),
        ],
      ),
    );
  }

  Widget _buildOverviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsList(BuildContext context, List<Payment> payments) {
    if (payments.isEmpty) {
      return EmptyState(message: context.tr('no_payments_found'));
    }
    final dateFormat = DateFormat.yMMMd();
    return Column(
      children: payments.map((payment) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.s),
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.medium,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.amount.toStringAsFixed(2),
                    style: AppTypography.labelLarge,
                  ),
                  Text(
                    paymentMethodLabel(context, payment.method),
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
              Text(
                dateFormat.format(payment.paymentDate),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _showRecordPaymentSheet(
    BuildContext context,
    String invoiceId,
  ) async {
    final invoiceDetailsBloc = context.read<InvoiceDetailsBloc>();
    final recorded = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => BlocProvider(
        create: (_) => getIt<PaymentFormBloc>(),
        child: _RecordPaymentSheet(invoiceId: invoiceId),
      ),
    );
    if (recorded == true && context.mounted) {
      invoiceDetailsBloc.add(FetchInvoiceDetailsRequested(invoiceId));
    }
  }
}

class _RecordPaymentSheet extends StatefulWidget {
  final String invoiceId;
  const _RecordPaymentSheet({required this.invoiceId});

  @override
  State<_RecordPaymentSheet> createState() => _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends State<_RecordPaymentSheet> {
  final _amountController = TextEditingController();
  final _referenceNumberController = TextEditingController();
  PaymentMethod _method = PaymentMethod.cash;
  DateTime? _paymentDate;

  @override
  void dispose() {
    _amountController.dispose();
    _referenceNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _paymentDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();
    return BlocListener<PaymentFormBloc, PaymentFormState>(
      listener: (context, state) {
        if (state is PaymentFormSuccess) {
          Navigator.of(context).pop(true);
        } else if (state is PaymentFormFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: BlocBuilder<PaymentFormBloc, PaymentFormState>(
        builder: (context, state) {
          final isSubmitting = state is PaymentFormSubmitting;
          return Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.m,
              right: AppSpacing.m,
              top: AppSpacing.m,
              bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.m,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('record_payment'), style: AppTypography.h3),
                const SizedBox(height: AppSpacing.m),
                AppTextField(
                  label: context.tr('amount'),
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                AppDropdownField<PaymentMethod>(
                  label: context.tr('method'),
                  value: _method,
                  backgroundColor: AppColors.surfaceLight,
                  items: PaymentMethod.values.where(
                    (m) => m != PaymentMethod.unknown,
                  ),
                  labelOf: (m) => paymentMethodLabel(context, m),
                  onChanged: (v) => setState(() => _method = v!),
                ),
                const SizedBox(height: AppSpacing.m),
                AppDateField(
                  label: context.tr('payment_date'),
                  value: _paymentDate,
                  dateFormat: dateFormat,
                  onTap: () => _pickDate(context),
                ),
                const SizedBox(height: AppSpacing.m),
                AppTextField(
                  label: context.tr('reference_number'),
                  controller: _referenceNumberController,
                ),
                const SizedBox(height: AppSpacing.l),
                AppButton(
                  text: context.tr('record_payment'),
                  isLoading: isSubmitting,
                  onPressed: () {
                    final amount = double.tryParse(_amountController.text);
                    final paymentDate = _paymentDate;
                    if (amount == null || paymentDate == null) return;
                    context.read<PaymentFormBloc>().add(
                      PaymentSubmitted(
                        CreatePaymentRequest(
                          invoiceId: widget.invoiceId,
                          amount: amount,
                          paymentDate: paymentDate,
                          method: _method,
                          referenceNumber:
                              _referenceNumberController.text.trim().isEmpty
                              ? null
                              : _referenceNumberController.text.trim(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
