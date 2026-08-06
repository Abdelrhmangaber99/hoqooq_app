import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_date_field.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../di/injection.dart';
import '../../data/models/create_invoice_request.dart';
import '../../data/models/update_invoice_request.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_status.dart';
import '../bloc/invoice_form_bloc.dart';
import '../finance_display_helpers.dart';

/// Shared Create/Edit screen — `existingInvoice == null` means create mode.
/// `UpdateInvoiceDto` leaves every field editable server-side, unlike
/// Cases (see `UpdateInvoiceRequest`'s doc comment) — this form matches
/// that exactly rather than locking fields down without a stated reason.
class InvoiceFormPage extends StatelessWidget {
  final Invoice? existingInvoice;

  const InvoiceFormPage({super.key, this.existingInvoice});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<InvoiceFormBloc>()
            ..add(LoadInvoiceFormReferenceDataRequested()),
      child: _InvoiceFormView(existingInvoice: existingInvoice),
    );
  }
}

class _InvoiceFormView extends StatefulWidget {
  final Invoice? existingInvoice;
  const _InvoiceFormView({this.existingInvoice});

  @override
  State<_InvoiceFormView> createState() => _InvoiceFormViewState();
}

class _InvoiceFormViewState extends State<_InvoiceFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _invoiceNumberController;
  late final TextEditingController _subtotalController;
  late final TextEditingController _taxTotalController;
  late final TextEditingController _grandTotalController;
  late final TextEditingController _notesController;
  late InvoiceStatus _status;
  String? _clientId;
  String? _caseId;
  DateTime? _issueDate;
  DateTime? _dueDate;

  bool get _isEditMode => widget.existingInvoice != null;

  @override
  void initState() {
    super.initState();
    final inv = widget.existingInvoice;
    _invoiceNumberController = TextEditingController(
      text: inv?.invoiceNumber ?? '',
    );
    _subtotalController = TextEditingController(
      text: inv != null ? inv.subtotal.toStringAsFixed(2) : '',
    );
    _taxTotalController = TextEditingController(
      text: inv != null ? inv.taxTotal.toStringAsFixed(2) : '',
    );
    _grandTotalController = TextEditingController(
      text: inv != null ? inv.grandTotal.toStringAsFixed(2) : '',
    );
    _notesController = TextEditingController(text: inv?.notes ?? '');
    _status = inv?.status ?? InvoiceStatus.draft;
    _clientId = inv?.clientId;
    _caseId = inv?.caseId;
    _issueDate = inv?.issueDate;
    _dueDate = inv?.dueDate;
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _subtotalController.dispose();
    _taxTotalController.dispose();
    _grandTotalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, {required bool isIssue}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isIssue ? _issueDate : _dueDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isIssue) {
          _issueDate = picked;
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  String? _blankToNull(String text) => text.trim().isEmpty ? null : text.trim();

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final bloc = context.read<InvoiceFormBloc>();
    final subtotal = double.tryParse(_subtotalController.text);
    final taxTotal = double.tryParse(_taxTotalController.text);
    final grandTotal = double.tryParse(_grandTotalController.text);
    if (subtotal == null || taxTotal == null || grandTotal == null) return;

    if (_isEditMode) {
      final original = widget.existingInvoice!;
      final request = UpdateInvoiceRequest(
        clientId: _clientId != original.clientId ? _clientId : null,
        caseId: _caseId != original.caseId ? _caseId : null,
        invoiceNumber:
            _invoiceNumberController.text.trim() != original.invoiceNumber
            ? _invoiceNumberController.text.trim()
            : null,
        subtotal: subtotal != original.subtotal ? subtotal : null,
        taxTotal: taxTotal != original.taxTotal ? taxTotal : null,
        grandTotal: grandTotal != original.grandTotal ? grandTotal : null,
        status: _status != original.status ? _status : null,
        issueDate: _issueDate != original.issueDate ? _issueDate : null,
        dueDate: _dueDate != original.dueDate ? _dueDate : null,
        notes: _blankToNull(_notesController.text) != original.notes
            ? _blankToNull(_notesController.text)
            : null,
      );
      bloc.add(UpdateInvoiceSubmitted(original.id, request));
    } else {
      final clientId = _clientId;
      final issueDate = _issueDate;
      final dueDate = _dueDate;
      if (clientId == null || issueDate == null || dueDate == null) return;
      final request = CreateInvoiceRequest(
        clientId: clientId,
        caseId: _caseId,
        invoiceNumber: _invoiceNumberController.text.trim(),
        subtotal: subtotal,
        taxTotal: taxTotal,
        grandTotal: grandTotal,
        status: _status,
        issueDate: issueDate,
        dueDate: dueDate,
        notes: _blankToNull(_notesController.text),
      );
      bloc.add(CreateInvoiceSubmitted(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEditMode ? context.tr('edit_invoice') : context.tr('new_invoice'),
        ),
      ),
      body: SafeArea(
        child: BlocListener<InvoiceFormBloc, InvoiceFormState>(
          listener: (context, state) {
            if (state is InvoiceFormSuccess) {
              context.pop(true);
            } else if (state is InvoiceFormReady && state.submitError != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.submitError!)));
            }
          },
          child: BlocBuilder<InvoiceFormBloc, InvoiceFormState>(
            builder: (context, state) {
              if (state is InvoiceFormLoading || state is InvoiceFormInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (state is! InvoiceFormReady) return const SizedBox();

              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: context.tr('invoice_number'),
                        controller: _invoiceNumberController,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? context.tr('field_required')
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppDropdownField<String?>(
                        label: context.tr('client'),
                        value: _clientId,
                        items: state.clients.map((c) => c.id),
                        labelOf: (id) => id == null
                            ? context.tr('none')
                            : state.clients
                                  .firstWhere((c) => c.id == id)
                                  .fullName,
                        onChanged: (v) => setState(() => _clientId = v),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppDropdownField<String?>(
                        label: context.tr('case'),
                        value: _caseId,
                        items: [null, ...state.cases.map((c) => c.id)],
                        labelOf: (id) => id == null
                            ? context.tr('none')
                            : state.cases
                                  .firstWhere((c) => c.id == id)
                                  .caseNumber,
                        onChanged: (v) => setState(() => _caseId = v),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppDropdownField<InvoiceStatus>(
                        label: context.tr('status'),
                        value: _status,
                        items: InvoiceStatus.values.where(
                          (s) => s != InvoiceStatus.unknown,
                        ),
                        labelOf: (s) => invoiceStatusLabel(context, s),
                        onChanged: (v) => setState(() => _status = v!),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppTextField(
                        label: context.tr('subtotal'),
                        controller: _subtotalController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (v) =>
                            v == null || double.tryParse(v) == null
                            ? context.tr('field_required')
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppTextField(
                        label: context.tr('tax_total'),
                        controller: _taxTotalController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (v) =>
                            v == null || double.tryParse(v) == null
                            ? context.tr('field_required')
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppTextField(
                        label: context.tr('grand_total'),
                        controller: _grandTotalController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (v) =>
                            v == null || double.tryParse(v) == null
                            ? context.tr('field_required')
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppDateField(
                        label: context.tr('issue_date'),
                        value: _issueDate,
                        dateFormat: dateFormat,
                        onTap: () => _pickDate(context, isIssue: true),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppDateField(
                        label: context.tr('due_date'),
                        value: _dueDate,
                        dateFormat: dateFormat,
                        onTap: () => _pickDate(context, isIssue: false),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppTextField(
                        label: context.tr('notes'),
                        controller: _notesController,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        text: _isEditMode
                            ? context.tr('save_changes')
                            : context.tr('create_invoice'),
                        isLoading: state.isSubmitting,
                        onPressed: () => _submit(context),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
