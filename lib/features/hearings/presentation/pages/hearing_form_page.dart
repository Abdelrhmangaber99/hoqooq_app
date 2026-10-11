import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/error_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_date_field.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../di/injection.dart';
import '../../../cases/domain/entities/court.dart';
import '../../data/models/create_hearing_request.dart';
import '../../data/models/complete_hearing_request.dart';
import '../../data/models/update_hearing_request.dart';
import '../../domain/entities/hearing.dart';
import '../../domain/entities/hearing_status.dart';
import '../bloc/hearing_form_bloc.dart';

/// Shared Create/Edit screen — `existingHearing == null` means create
/// mode, always scoped to [caseId]. Completion is submitted through the
/// backend's dedicated endpoint.
class HearingFormPage extends StatelessWidget {
  final String caseId;
  final Hearing? existingHearing;
  final String? governorateId;

  const HearingFormPage({
    super.key,
    required this.caseId,
    this.existingHearing,
    this.governorateId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<HearingFormBloc>()
            ..add(
              LoadHearingFormReferenceDataRequested(
                governorateId,
                initialCourtId: existingHearing?.courtId,
              ),
            ),
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
  String? _circuitId;
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
    _circuitId = h?.circuitId;
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
      );
      bloc.add(UpdateHearingSubmitted(original.id, request));
    } else {
      final courtId = _courtId;
      final hearingTypeId = _hearingTypeId;
      final scheduledAt = _scheduledAt;
      if (courtId == null || hearingTypeId == null || scheduledAt == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('hearing_required_fields'))),
        );
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
        circuitId: _circuitId,
      );
      bloc.add(CreateHearingSubmitted(request));
    }
  }

  void _complete(BuildContext context) {
    final outcome = _outcomeTextController.text.trim();
    if (outcome.length < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('hearing_outcome_min_length'))),
      );
      return;
    }
    context.read<HearingFormBloc>().add(
      CompleteHearingSubmitted(
        widget.existingHearing!.id,
        CompleteHearingRequest(
          outcomeText: outcome,
          nextHearingAt: _nextHearingAt,
        ),
      ),
    );
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
              context.showErrorSnackBar(state.submitError);
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
                      if (state.courts.isEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.m),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: AppColors.warning,
                                ),
                                const SizedBox(width: AppSpacing.s),
                                Expanded(
                                  child: Text(
                                    state.courtLoadError == null
                                        ? context.tr(
                                            'no_backend_courts_for_hearing',
                                          )
                                        : '${context.tr('court_load_failed')} ${state.courtLoadError}',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        AppDropdownField<String?>(
                          label: context.tr('court'),
                          value: _courtId,
                          items: [null, ...state.courts.map((c) => c.id)],
                          labelOf: (id) => id == null
                              ? context.tr('none')
                              : state.courts
                                    .firstWhere((c) => c.id == id)
                                    .labelFor(locale.languageCode),
                          onChanged: (v) {
                            setState(() {
                              _courtId = v;
                              _circuitId = null;
                            });
                            if (v != null) {
                              context.read<HearingFormBloc>().add(
                                LoadHearingCircuitsRequested(v),
                              );
                            }
                          },
                        ),
                      const SizedBox(height: AppSpacing.m),
                      if (_courtId != null && state.circuits.isEmpty)
                        Text(
                          context.tr('no_circuits_optional'),
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      else if (state.circuits.isNotEmpty)
                        AppDropdownField<String?>(
                          label: context.tr('circuit'),
                          value: _circuitId,
                          items: [null, ...state.circuits.map((c) => c.id)],
                          labelOf: (id) => id == null
                              ? context.tr('none')
                              : state.circuits
                                    .firstWhere((c) => c.id == id)
                                    .labelFor(locale.languageCode),
                          onChanged: (v) => setState(() => _circuitId = v),
                        ),
                      const SizedBox(height: AppSpacing.m),
                      if (state.hearingTypes.isEmpty &&
                          state.hearingTypeLoadError != null) ...[
                        Text(
                          '${context.tr('hearing_type_load_failed')} ${state.hearingTypeLoadError}',
                          style: const TextStyle(color: AppColors.error),
                        ),
                        const SizedBox(height: AppSpacing.m),
                      ],
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
                      if (_isEditMode &&
                          _status != HearingStatus.completed &&
                          _status != HearingStatus.cancelled) ...[
                        AppTextField(
                          label: context.tr('outcome_text'),
                          controller: _outcomeTextController,
                        ),
                        const SizedBox(height: AppSpacing.m),
                        AppDateField(
                          label: context.tr('next_hearing_at'),
                          value: _nextHearingAt,
                          dateFormat: dateFormat,
                          onTap: () =>
                              _pickDateTime(context, isScheduled: false),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        AppButton(
                          text: context.tr('complete_hearing'),
                          isLoading: state.isSubmitting,
                          onPressed: () => _complete(context),
                        ),
                        const SizedBox(height: AppSpacing.m),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        text: _isEditMode
                            ? context.tr('save_changes')
                            : context.tr('create_hearing'),
                        isLoading: state.isSubmitting,
                        onPressed:
                            state.courts.isEmpty || state.hearingTypes.isEmpty
                            ? null
                            : () => _submit(context),
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
