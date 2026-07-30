import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../di/injection.dart';
import '../../../authentication/presentation/bloc/session_cubit.dart';
import '../../data/models/update_case_request.dart';
import '../../domain/entities/case_priority.dart';
import '../../domain/entities/case_status.dart';
import '../../domain/entities/legal_case.dart';
import '../bloc/case_form_bloc.dart';
import '../case_display_helpers.dart';

/// Update-only — there is no create-case flow this milestone (see
/// `ICaseRepository`'s doc comment). `caseType`/`caseNumber`/`client` are
/// shown read-only; every other field is editable.
class CaseFormPage extends StatelessWidget {
  final LegalCase existingCase;

  const CaseFormPage({super.key, required this.existingCase});

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
  final LegalCase existingCase;
  const _CaseFormView({required this.existingCase});

  @override
  State<_CaseFormView> createState() => _CaseFormViewState();
}

class _CaseFormViewState extends State<_CaseFormView> {
  late final TextEditingController _outcomeSummaryController;
  late final TextEditingController _agreedFeeController;
  late CaseStatus _status;
  late CasePriority _priority;
  String? _primaryLawyerId;
  String? _defaultCourtId;
  DateTime? _openingDate;
  DateTime? _closingDate;

  bool get _isFirmAdmin {
    final sessionState = getIt<SessionCubit>().state;
    return sessionState is SessionAuthenticated && sessionState.isFirmAdmin;
  }

  @override
  void initState() {
    super.initState();
    final c = widget.existingCase;
    _outcomeSummaryController = TextEditingController(
      text: c.outcomeSummary ?? '',
    );
    _agreedFeeController = TextEditingController(
      text: c.agreedFee != null ? c.agreedFee!.toStringAsFixed(2) : '',
    );
    _status = c.status;
    _priority = c.priority;
    _primaryLawyerId = c.primaryLawyerId;
    _defaultCourtId = c.defaultCourtId;
    _openingDate = c.openingDate;
    _closingDate = c.closingDate;
  }

  @override
  void dispose() {
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
    final original = widget.existingCase;
    final request = UpdateCaseRequest(
      primaryLawyerId: _primaryLawyerId != original.primaryLawyerId
          ? _primaryLawyerId
          : null,
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
    context.read<CaseFormBloc>().add(UpdateCaseSubmitted(original.id, request));
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(context.tr('edit_case'))),
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

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${context.tr('case_number')}: ${widget.existingCase.caseNumber}',
                      style: const TextStyle(color: AppColors.textHint),
                    ),
                    Text(
                      '${context.tr('case_type')}: '
                      '${widget.existingCase.caseType?.name ?? context.tr('unknown')}',
                      style: const TextStyle(color: AppColors.textHint),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _buildDropdown<CaseStatus>(
                      label: context.tr('status'),
                      value: _status,
                      items: CaseStatus.values.where(
                        (s) => s != CaseStatus.unknown,
                      ),
                      labelOf: (s) => caseStatusLabel(context, s),
                      onChanged: (v) => setState(() => _status = v!),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _buildDropdown<CasePriority>(
                      label: context.tr('priority'),
                      value: _priority,
                      items: CasePriority.values.where(
                        (p) => p != CasePriority.unknown,
                      ),
                      labelOf: (p) => casePriorityLabel(context, p),
                      onChanged: (v) => setState(() => _priority = v!),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _buildDropdown<String?>(
                      label: context.tr('court'),
                      value: _defaultCourtId,
                      items: [null, ...state.courts.map((c) => c.id)],
                      labelOf: (id) => id == null
                          ? context.tr('none')
                          : state.courts.firstWhere((c) => c.id == id).name,
                      onChanged: (v) => setState(() => _defaultCourtId = v),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _buildDropdown<String?>(
                      label: context.tr('primary_lawyer'),
                      value: _primaryLawyerId,
                      items: [null, ...state.users.map((u) => u.id)],
                      labelOf: (id) => id == null
                          ? context.tr('none')
                          : state.users.firstWhere((u) => u.id == id).fullName,
                      onChanged: (v) => setState(() => _primaryLawyerId = v),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _buildDateField(
                      label: context.tr('opening_date'),
                      value: _openingDate,
                      dateFormat: dateFormat,
                      onTap: () => _pickDate(context, isOpening: true),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _buildDateField(
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
                      text: context.tr('save_changes'),
                      isLoading: state.isSubmitting,
                      onPressed: () => _submit(context),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required Iterable<T> items,
    required String Function(T) labelOf,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              items: items
                  .map(
                    (i) => DropdownMenuItem(value: i, child: Text(labelOf(i))),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required DateFormat dateFormat,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value != null ? dateFormat.format(value) : '—',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }
}
