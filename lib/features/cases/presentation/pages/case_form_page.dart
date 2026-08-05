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
import '../../../authentication/presentation/bloc/session_cubit.dart';
import '../../../lookups/domain/entities/lookup.dart';
import '../../data/models/create_case_request.dart';
import '../../data/models/update_case_request.dart';
import '../../domain/entities/case_priority.dart';
import '../../domain/entities/case_status.dart';
import '../../domain/entities/legal_case.dart';
import '../bloc/case_form_bloc.dart';
import '../case_display_helpers.dart';

/// Shared Create/Edit screen — `existingCase == null` means create mode.
/// `caseNumber`/`clientId`/`caseTypeId` are only ever set on create; the
/// edit form redisplays them read-only (`caseTypeId` resolved to a label
/// via the loaded case-type Lookups, same list the create-mode dropdown
/// uses). No primary-lawyer field anywhere — removed from the backend
/// schema entirely (API_CONTRACT.md finding N); team membership is a
/// separate action on `CaseDetailsPage`.
class CaseFormPage extends StatelessWidget {
  final LegalCase? existingCase;

  const CaseFormPage({super.key, this.existingCase});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<CaseFormBloc>()..add(LoadCaseFormReferenceDataRequested()),
      child: _CaseFormView(existingCase: existingCase),
    );
  }
}

class _CaseFormView extends StatefulWidget {
  final LegalCase? existingCase;
  const _CaseFormView({this.existingCase});

  @override
  State<_CaseFormView> createState() => _CaseFormViewState();
}

class _CaseFormViewState extends State<_CaseFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _caseNumberController;
  late final TextEditingController _outcomeSummaryController;
  late final TextEditingController _agreedFeeController;
  late CaseStatus _status;
  late CasePriority _priority;
  String? _clientId;
  String? _caseTypeId;
  String? _defaultCourtId;
  DateTime? _openingDate;
  DateTime? _closingDate;

  bool get _isEditMode => widget.existingCase != null;

  bool get _isFirmAdmin {
    final sessionState = getIt<SessionCubit>().state;
    return sessionState is SessionAuthenticated && sessionState.isFirmAdmin;
  }

  @override
  void initState() {
    super.initState();
    final c = widget.existingCase;
    _caseNumberController = TextEditingController(text: c?.caseNumber ?? '');
    _outcomeSummaryController = TextEditingController(
      text: c?.outcomeSummary ?? '',
    );
    _agreedFeeController = TextEditingController(
      text: c?.agreedFee != null ? c!.agreedFee!.toStringAsFixed(2) : '',
    );
    _status = c?.status ?? CaseStatus.draft;
    _priority = c?.priority ?? CasePriority.normal;
    _clientId = c?.clientId;
    _caseTypeId = c?.caseTypeId;
    _defaultCourtId = c?.defaultCourtId;
    _openingDate = c?.openingDate;
    _closingDate = c?.closingDate;
  }

  @override
  void dispose() {
    _caseNumberController.dispose();
    _outcomeSummaryController.dispose();
    _agreedFeeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
    BuildContext context, {
    required bool isOpening,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isOpening ? _openingDate : _closingDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isOpening) {
          _openingDate = picked;
        } else {
          _closingDate = picked;
        }
      });
    }
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final bloc = context.read<CaseFormBloc>();

    if (_isEditMode) {
      final original = widget.existingCase!;
      final request = UpdateCaseRequest(
        defaultCourtId: _defaultCourtId != original.defaultCourtId
            ? _defaultCourtId
            : null,
        status: _status != original.status ? _status : null,
        openingDate: _openingDate != original.openingDate ? _openingDate : null,
        closingDate: _closingDate != original.closingDate ? _closingDate : null,
        outcomeSummary:
            _outcomeSummaryController.text.trim() !=
                (original.outcomeSummary ?? '')
            ? (_outcomeSummaryController.text.trim().isEmpty
                  ? null
                  : _outcomeSummaryController.text.trim())
            : null,
        agreedFee:
            _isFirmAdmin &&
                double.tryParse(_agreedFeeController.text) != original.agreedFee
            ? double.tryParse(_agreedFeeController.text)
            : null,
        priority: _priority != original.priority ? _priority : null,
      );
      bloc.add(UpdateCaseSubmitted(original.id, request));
    } else {
      final clientId = _clientId;
      final caseTypeId = _caseTypeId;
      if (clientId == null || caseTypeId == null) return;
      final request = CreateCaseRequest(
        caseNumber: _caseNumberController.text.trim(),
        clientId: clientId,
        caseTypeId: caseTypeId,
        defaultCourtId: _defaultCourtId,
        status: _status,
        openingDate: _openingDate,
        closingDate: _closingDate,
        outcomeSummary: _outcomeSummaryController.text.trim().isEmpty
            ? null
            : _outcomeSummaryController.text.trim(),
        agreedFee: _isFirmAdmin
            ? double.tryParse(_agreedFeeController.text)
            : null,
        priority: _priority,
      );
      bloc.add(CreateCaseSubmitted(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();
    final locale = Localizations.localeOf(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEditMode ? context.tr('edit_case') : context.tr('new_case'),
        ),
      ),
      body: SafeArea(
        child: BlocListener<CaseFormBloc, CaseFormState>(
          listener: (context, state) {
            if (state is CaseFormSuccess) {
              context.pop(true);
            } else if (state is CaseFormReady && state.submitError != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.submitError!)));
            }
          },
          child: BlocBuilder<CaseFormBloc, CaseFormState>(
            builder: (context, state) {
              if (state is CaseFormLoading || state is CaseFormInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (state is! CaseFormReady) return const SizedBox();

              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isEditMode) ...[
                        Text(
                          '${context.tr('case_number')}: ${widget.existingCase!.caseNumber}',
                          style: const TextStyle(color: AppColors.textHint),
                        ),
                        Text(
                          '${context.tr('case_type')}: '
                          '${_resolveCaseTypeLabel(state.caseTypes, widget.existingCase!.caseTypeId, locale, context)}',
                          style: const TextStyle(color: AppColors.textHint),
                        ),
                        const SizedBox(height: AppSpacing.m),
                      ] else ...[
                        AppTextField(
                          label: context.tr('case_number'),
                          controller: _caseNumberController,
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
                          label: context.tr('case_type'),
                          value: _caseTypeId,
                          items: state.caseTypes.map((l) => l.id),
                          labelOf: (id) => id == null
                              ? context.tr('none')
                              : state.caseTypes
                                    .firstWhere((l) => l.id == id)
                                    .labelFor(locale),
                          onChanged: (v) => setState(() => _caseTypeId = v),
                        ),
                        const SizedBox(height: AppSpacing.m),
                      ],
                      AppDropdownField<CaseStatus>(
                        label: context.tr('status'),
                        value: _status,
                        items: CaseStatus.values.where(
                          (s) => s != CaseStatus.unknown,
                        ),
                        labelOf: (s) => caseStatusLabel(context, s),
                        onChanged: (v) => setState(() => _status = v!),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppDropdownField<CasePriority>(
                        label: context.tr('priority'),
                        value: _priority,
                        items: CasePriority.values.where(
                          (p) => p != CasePriority.unknown,
                        ),
                        labelOf: (p) => casePriorityLabel(context, p),
                        onChanged: (v) => setState(() => _priority = v!),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppDropdownField<String?>(
                        label: context.tr('court'),
                        value: _defaultCourtId,
                        items: [null, ...state.courts.map((c) => c.id)],
                        labelOf: (id) => id == null
                            ? context.tr('none')
                            : state.courts.firstWhere((c) => c.id == id).name,
                        onChanged: (v) => setState(() => _defaultCourtId = v),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppDateField(
                        label: context.tr('opening_date'),
                        value: _openingDate,
                        dateFormat: dateFormat,
                        onTap: () => _pickDate(context, isOpening: true),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppDateField(
                        label: context.tr('closing_date'),
                        value: _closingDate,
                        dateFormat: dateFormat,
                        onTap: () => _pickDate(context, isOpening: false),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppTextField(
                        label: context.tr('outcome_summary'),
                        controller: _outcomeSummaryController,
                      ),
                      if (_isFirmAdmin) ...[
                        const SizedBox(height: AppSpacing.m),
                        AppTextField(
                          label: context.tr('agreed_fee'),
                          controller: _agreedFeeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        text: _isEditMode
                            ? context.tr('save_changes')
                            : context.tr('create_case'),
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

  String _resolveCaseTypeLabel(
    List<Lookup> caseTypes,
    String caseTypeId,
    Locale locale,
    BuildContext context,
  ) {
    for (final lookup in caseTypes) {
      if (lookup.id == caseTypeId) return lookup.labelFor(locale);
    }
    return context.tr('unknown');
  }
}
