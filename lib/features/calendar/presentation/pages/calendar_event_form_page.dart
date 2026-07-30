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
import '../../data/models/create_event_request.dart';
import '../bloc/calendar_event_form_bloc.dart';

/// New custom calendar event screen. `CUSTOM` is the only event type ever
/// created here — `HEARING`/`TASK_DEADLINE` items are server-derived, not
/// user-created (see PLAN.md's M4 Calendar scope decision). `userId`
/// always defaults to the current authenticated user, same pattern as
/// `TaskFormPage`'s `assignedById` — not shown as an editable field.
class CalendarEventFormPage extends StatelessWidget {
  const CalendarEventFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CalendarEventFormBloc>(),
      child: const _CalendarEventFormView(),
    );
  }
}

class _CalendarEventFormView extends StatefulWidget {
  const _CalendarEventFormView();

  @override
  State<_CalendarEventFormView> createState() => _CalendarEventFormViewState();
}

class _CalendarEventFormViewState extends State<_CalendarEventFormView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _startsAt;
  DateTime? _endsAt;
  bool _isAllDay = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDateTime(
    BuildContext context,
    DateTime? initial,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;
    if (_isAllDay || !context.mounted) return date;

    final time = await showTimePicker(
      context: context,
      initialTime: initial != null
          ? TimeOfDay.fromDateTime(initial)
          : TimeOfDay.now(),
    );
    if (time == null) return date;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String? _currentUserId() {
    final sessionState = getIt<SessionCubit>().state;
    return sessionState is SessionAuthenticated ? sessionState.user.id : null;
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final startsAt = _startsAt;
    final userId = _currentUserId();
    if (startsAt == null || userId == null) return;

    final request = CreateEventRequest(
      userId: userId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      startsAt: startsAt,
      endsAt: _endsAt,
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      isAllDay: _isAllDay,
    );
    context.read<CalendarEventFormBloc>().add(CreateEventSubmitted(request));
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd().add_jm();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(context.tr('new_event'))),
      body: SafeArea(
        child: BlocListener<CalendarEventFormBloc, CalendarEventFormState>(
          listener: (context, state) {
            if (state is CalendarEventFormSuccess) {
              context.pop(true);
            } else if (state is CalendarEventFormFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: BlocBuilder<CalendarEventFormBloc, CalendarEventFormState>(
            builder: (context, state) {
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: context.tr('title'),
                        controller: _titleController,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? context.tr('field_required')
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppTextField(
                        label: context.tr('description'),
                        controller: _descriptionController,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppTextField(
                        label: context.tr('location'),
                        controller: _locationController,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: AppColors.primary,
                        title: Text(context.tr('all_day')),
                        value: _isAllDay,
                        onChanged: (v) => setState(() => _isAllDay = v),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      _buildDateField(
                        label: context.tr('start_date'),
                        value: _startsAt,
                        dateFormat: dateFormat,
                        onTap: () async {
                          final picked = await _pickDateTime(
                            context,
                            _startsAt,
                          );
                          if (picked != null) {
                            setState(() => _startsAt = picked);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.m),
                      _buildDateField(
                        label: context.tr('end_date'),
                        value: _endsAt,
                        dateFormat: dateFormat,
                        onTap: () async {
                          final picked = await _pickDateTime(context, _endsAt);
                          if (picked != null) {
                            setState(() => _endsAt = picked);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        text: context.tr('create_event'),
                        isLoading: state is CalendarEventFormSubmitting,
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
