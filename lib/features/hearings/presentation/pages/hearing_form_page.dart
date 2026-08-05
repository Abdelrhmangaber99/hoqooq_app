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
import '../../data/models/create_hearing_request.dart';
import '../../data/models/update_hearing_request.dart';
import '../../domain/entities/hearing.dart';
import '../../domain/entities/hearing_status.dart';
import '../bloc/hearing_form_bloc.dart';
import '../hearing_display_helpers.dart';

/// Shared Create/Edit screen — `existingHearing == null` means create
/// mode, always scoped to [caseId] (a hearing always belongs to exactly
/// one case, unlike Task creation's optional case link). "Complete a
/// hearing" is just this same form with `status: completed` + an outcome.
class HearingFormPage extends StatelessWidget {
  final String caseId;
  final Hearing? existingHearing;

  const HearingFormPage({
    super.key,
    required this.caseId,
    this.existingHearing,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<HearingFormBloc>()
            ..add(LoadHearingFormReferenceDataRequested()),
      child: _HearingFormView(caseId: caseId, existingHearing: existingHearing),
    );
  }
}

class _HearingFormView extends StatefulWidget {
  final String caseId;
  final Hearing? existingHearing;
  const _HearingFormView({required this.caseId, this.existingHearing});

  @override
  State<_HearingFormView> createState() => _HearingFormViewState();
}

class _HearingFormViewState extends State<_HearingFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judgeNameController;
  late final TextEditingController _outcomeTextController;
  late HearingStatus _status;
  String? _courtId;
  String? _hearingTypeId;
  DateTime? _scheduledAt;
  DateTime? _nextHearingAt;

  bool get _isEditMode => widget.existingHearing != null;

  @override
  void initState() {
    super.initState();
    final h = widget.existingHearing;
    _judgeNameController = TextEditingController(text: h?.judgeName ?? '');
    _outcomeTextController = TextEditingController(text: h?.outcomeText ?? '');
    _status = h?.status ?? HearingStatus.scheduled;
    _courtId = h?.courtId;
    _hearingTypeId = h?.hearingTypeId;
    _scheduledAt = h?.scheduledAt;
    _nextHearingAt = h?.nextHearingAt;
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
    final bloc = context.read<HearingFormBloc>();

    if (_isEditMode) {
      final original = widget.existingHearing!;
      final request = UpdateHearingRequest(
        courtId: _courtId != original.courtId ? _courtId : null,
        scheduledAt: _scheduledAt != original.scheduledAt ? _scheduledAt : null,
        judgeName:
            _judgeNameController.text.trim() != (original.judgeName ?? '')
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
      bloc.add(UpdateHearingSubmitted(original.id, request));
    } else {
      final courtId = _courtId;
      final hearingTypeId = _hearingTypeId;
      final scheduledAt = _scheduledAt;
      if (courtId == null || hearingTypeId == null || scheduledAt == null) {
        return;
      }
      final request = CreateHearingRequest(
        caseId: widget.caseId,
        courtId: courtId,
        hearingTypeId: hearingTypeId,
        scheduledAt: scheduledAt,
        judgeName: _judgeNameController.text.trim().isEmpty
            ? null
            : _judgeNameController.text.trim(),
        status: _status,
        outcomeText: _outcomeTextController.text.trim().isEmpty
            ? null
            : _outcomeTextController.text.trim(),
        nextHearingAt: _nextHearingAt,
      );
      bloc.add(CreateHearingSubmitted(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd().add_jm();
    final locale = Localizations.localeOf(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEditMode ? context.tr('edit_hearing') : context.tr('new_hearing'),
        ),
      ),
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

              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_isEditMode) ...[
                        AppDropdownField<String?>(
                          label: context.tr('hearing_type'),
                          value: _hearingTypeId,
                          items: state.hearingTypes.map((l) => l.id),
                          labelOf: (id) => id == null
                              ? context.tr('none')
                              : state.hearingTypes
                                    .firstWhere((l) => l.id == id)
                                    .labelFor(locale),
                          onChanged: (v) => setState(() => _hearingTypeId = v),
                        ),
                        const SizedBox(height: AppSpacing.m),
                      ],
                      AppDropdownField<HearingStatus>(
                        label: context.tr('status'),
                        value: _status,
                        items: HearingStatus.values.where(
                          (s) => s != HearingStatus.unknown,
                        ),
                        labelOf: (s) => hearingStatusLabel(context, s),
                        onChanged: (v) => setState(() => _status = v!),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppDropdownField<String?>(
                        label: context.tr('court'),
                        value: _courtId,
                        items: [null, ...state.courts.map((c) => c.id)],
                        labelOf: (id) => id == null
                            ? context.tr('none')
                            : state.courts.firstWhere((c) => c.id == id).name,
                        onChanged: (v) => setState(() => _courtId = v),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppDateField(
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
                      AppDateField(
                        label: context.tr('next_hearing_at'),
                        value: _nextHearingAt,
                        dateFormat: dateFormat,
                        onTap: () => _pickDateTime(context, isScheduled: false),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        text: _isEditMode
                            ? context.tr('save_changes')
                            : context.tr('create_hearing'),
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
