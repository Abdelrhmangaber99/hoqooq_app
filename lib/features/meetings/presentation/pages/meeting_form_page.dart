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
import '../../../../core/widgets/app_text_field.dart';
import '../../../../di/injection.dart';
import '../../data/models/meeting_requests.dart';
import '../../domain/entities/client_meeting.dart';
import '../bloc/meeting_form_bloc.dart';

class MeetingFormPage extends StatelessWidget {
  const MeetingFormPage({super.key, required this.caseId, this.existing});
  final String caseId;
  final ClientMeeting? existing;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<MeetingFormBloc>(),
    child: _MeetingFormView(caseId: caseId, existing: existing),
  );
}

class _MeetingFormView extends StatefulWidget {
  const _MeetingFormView({required this.caseId, this.existing});
  final String caseId;
  final ClientMeeting? existing;
  @override
  State<_MeetingFormView> createState() => _MeetingFormViewState();
}

class _MeetingFormViewState extends State<_MeetingFormView> {
  late final TextEditingController _subject;
  late final TextEditingController _location;
  late final TextEditingController _notes;
  DateTime? _scheduledAt;
  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _subject = TextEditingController(text: widget.existing?.subject ?? '');
    _location = TextEditingController(
      text: widget.existing?.locationOrMethod ?? '',
    );
    _notes = TextEditingController(text: widget.existing?.notes ?? '');
    _scheduledAt = widget.existing?.scheduledAt;
  }

  @override
  void dispose() {
    _subject.dispose();
    _location.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final current = _scheduledAt ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null) return;
    setState(
      () => _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  String? get _optionalNotes =>
      _notes.text.trim().isEmpty ? null : _notes.text.trim();
  void _submit() {
    final subject = _subject.text.trim();
    final location = _location.text.trim();
    if (subject.isEmpty || location.isEmpty || _scheduledAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('complete_meeting_fields'))),
      );
      return;
    }
    final bloc = context.read<MeetingFormBloc>();
    if (_editing) {
      bloc.add(
        UpdateMeetingSubmitted(
          widget.existing!.id,
          UpdateMeetingRequest(
            scheduledAt: _scheduledAt,
            locationOrMethod: location,
            subject: subject,
            notes: _optionalNotes,
          ),
        ),
      );
    } else {
      bloc.add(
        CreateMeetingSubmitted(
          CreateMeetingRequest(
            caseId: widget.caseId,
            scheduledAt: _scheduledAt!,
            locationOrMethod: location,
            subject: subject,
            notes: _optionalNotes,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: Text(
        context.tr(_editing ? 'edit_client_meeting' : 'new_client_meeting'),
      ),
    ),
    body: BlocConsumer<MeetingFormBloc, MeetingFormState>(
      listener: (context, state) {
        if (state is MeetingFormSuccess) {
          context.pop(true);
        }
        if (state is MeetingFormReady && state.submitError != null) {
          context.showErrorSnackBar(state.submitError);
        }
      },
      builder: (context, state) {
        if (state is! MeetingFormReady) return const SizedBox();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            children: [
              AppTextField(
                label: context.tr('meeting_subject'),
                controller: _subject,
              ),
              const SizedBox(height: AppSpacing.m),
              AppTextField(
                label: context.tr('meeting_location_method'),
                controller: _location,
              ),
              const SizedBox(height: AppSpacing.m),
              AppDateField(
                label: context.tr('scheduled_at'),
                value: _scheduledAt,
                dateFormat: DateFormat.yMMMd().add_jm(),
                onTap: _pickDate,
              ),
              const SizedBox(height: AppSpacing.m),
              AppTextField(label: context.tr('notes'), controller: _notes),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                text: context.tr(
                  _editing ? 'save_changes' : 'create_client_meeting',
                ),
                isLoading: state.isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        );
      },
    ),
  );
}
