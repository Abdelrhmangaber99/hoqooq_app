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
import '../../data/models/update_hearing_request.dart';
import '../../domain/entities/hearing.dart';
import '../../domain/entities/hearing_status.dart';
import '../bloc/hearing_form_bloc.dart';
import '../hearing_display_helpers.dart';

/// Update-only — there is no create-hearing flow this milestone (see
/// `IHearingRepository`'s doc comment). "Complete a hearing" is just
/// setting status to completed + an outcome, through this same form.
class HearingFormPage extends StatelessWidget {
  final Hearing existingHearing;

  const HearingFormPage({super.key, required this.existingHearing});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<HearingFormBloc>()
            ..add(LoadHearingFormReferenceDataRequested()),
      child: _HearingFormView(existingHearing: existingHearing),
    );
  }
}

class _HearingFormView extends StatefulWidget {
  final Hearing existingHearing;
  const _HearingFormView({required this.existingHearing});

  @override
  State<_HearingFormView> createState() => _HearingFormViewState();
}

class _HearingFormViewState extends State<_HearingFormView> {
  late final TextEditingController _judgeNameController;
  late final TextEditingController _outcomeTextController;
  late HearingStatus _status;
  String? _courtId;
  DateTime? _scheduledAt;
  DateTime? _nextHearingAt;

  @override
  void initState() {
    super.initState();
    final h = widget.existingHearing;
    _judgeNameController = TextEditingController(text: h.judgeName ?? '');
    _outcomeTextController = TextEditingController(text: h.outcomeText ?? '');
    _status = h.status;
    _courtId = h.courtId;
    _scheduledAt = h.scheduledAt;
    _nextHearingAt = h.nextHearingAt;
  }

  @override
  void dispose() {
    _judgeNameController.dispose();
    _outcomeTextController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(
    BuildContext context, {
    required bool isScheduled,
  }) async {
    final current =
        (isScheduled ? _scheduledAt : _nextHearingAt) ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null) return;
    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (isScheduled) {
        _scheduledAt = combined;
      } else {
        _nextHearingAt = combined;
      }
    });
  }

  void _submit(BuildContext context) {
    final original = widget.existingHearing;
    final request = UpdateHearingRequest(
      courtId: _courtId != original.courtId ? _courtId : null,
      scheduledAt: _scheduledAt != original.scheduledAt ? _scheduledAt : null,
      judgeName: _judgeNameController.text.trim() != (original.judgeName ?? '')
          ? (_judgeNameController.text.trim().isEmpty
                ? null
                : _judgeNameController.text.trim())
          : null,
      status: _status != original.status ? _status : null,
      outcomeText:
          _outcomeTextController.text.trim() != (original.outcomeText ?? '')
          ? (_outcomeTextController.text.trim().isEmpty
                ? null
                : _outcomeTextController.text.trim())
          : null,
      nextHearingAt: _nextHearingAt != original.nextHearingAt
          ? _nextHearingAt
          : null,
    );
    context.read<HearingFormBloc>().add(
      UpdateHearingSubmitted(original.id, request),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd().add_jm();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(context.tr('edit_hearing'))),
      body: SafeArea(
        child: BlocListener<HearingFormBloc, HearingFormState>(
          listener: (context, state) {
            if (state is HearingFormSuccess) {
              context.pop(true);
            } else if (state is HearingFormReady && state.submitError != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.submitError!)));
            }
          },
          child: BlocBuilder<HearingFormBloc, HearingFormState>(
            builder: (context, state) {
              if (state is HearingFormLoading || state is HearingFormInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (state is! HearingFormReady) return const SizedBox();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDropdown<HearingStatus>(
                      label: context.tr('status'),
                      value: _status,
                      items: HearingStatus.values.where(
                        (s) => s != HearingStatus.unknown,
                      ),
                      labelOf: (s) => hearingStatusLabel(context, s),
                      onChanged: (v) => setState(() => _status = v!),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _buildDropdown<String?>(
                      label: context.tr('court'),
                      value: _courtId,
                      items: [null, ...state.courts.map((c) => c.id)],
                      labelOf: (id) => id == null
                          ? context.tr('none')
                          : state.courts.firstWhere((c) => c.id == id).name,
                      onChanged: (v) => setState(() => _courtId = v),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _buildDateTimeField(
                      label: context.tr('scheduled_at'),
                      value: _scheduledAt,
                      dateFormat: dateFormat,
                      onTap: () => _pickDateTime(context, isScheduled: true),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    AppTextField(
                      label: context.tr('judge'),
                      controller: _judgeNameController,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    AppTextField(
                      label: context.tr('outcome_text'),
                      controller: _outcomeTextController,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _buildDateTimeField(
                      label: context.tr('next_hearing_at'),
                      value: _nextHearingAt,
                      dateFormat: dateFormat,
                      onTap: () => _pickDateTime(context, isScheduled: false),
                    ),
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

  Widget _buildDateTimeField({
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
