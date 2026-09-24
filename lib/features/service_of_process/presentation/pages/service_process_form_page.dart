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
import '../../data/models/create_service_process_request.dart';
import '../../data/models/update_service_process_request.dart';
import '../../domain/entities/service_process.dart';
import '../bloc/service_process_form_bloc.dart';

class ServiceProcessFormPage extends StatelessWidget {
  const ServiceProcessFormPage({
    super.key,
    required this.caseId,
    this.governorateId,
    this.existing,
  });

  final String caseId;
  final String? governorateId;
  final ServiceProcess? existing;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        getIt<ServiceProcessFormBloc>()
          ..add(LoadServiceProcessFormRequested(governorateId)),
    child: _ServiceProcessFormView(caseId: caseId, existing: existing),
  );
}

class _ServiceProcessFormView extends StatefulWidget {
  const _ServiceProcessFormView({required this.caseId, this.existing});
  final String caseId;
  final ServiceProcess? existing;

  @override
  State<_ServiceProcessFormView> createState() =>
      _ServiceProcessFormViewState();
}

class _ServiceProcessFormViewState extends State<_ServiceProcessFormView> {
  late final TextEditingController _target;
  late final TextEditingController _server;
  late final TextEditingController _recipient;
  late final TextEditingController _notes;
  String? _methodId;
  String? _courtId;
  DateTime? _scheduledAt;
  DateTime? _deadlineAt;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final item = widget.existing;
    _target = TextEditingController(text: item?.targetName ?? '');
    _server = TextEditingController(text: item?.processServerName ?? '');
    _recipient = TextEditingController(text: item?.recipientDetails ?? '');
    _notes = TextEditingController(text: item?.notes ?? '');
    _methodId = item?.serviceMethodId;
    _courtId = item?.courtId;
    _scheduledAt = item?.scheduledAt;
    _deadlineAt = item?.deadlineAt;
  }

  @override
  void dispose() {
    _target.dispose();
    _server.dispose();
    _recipient.dispose();
    _notes.dispose();
    super.dispose();
  }

  String? _optional(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _pickDate(bool deadline) async {
    final current = (deadline ? _deadlineAt : _scheduledAt) ?? DateTime.now();
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
    setState(() {
      final value = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (deadline) {
        _deadlineAt = value;
      } else {
        _scheduledAt = value;
      }
    });
  }

  void _submit() {
    final target = _target.text.trim();
    if (target.isEmpty || _methodId == null || _scheduledAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('complete_service_fields'))),
      );
      return;
    }
    final bloc = context.read<ServiceProcessFormBloc>();
    if (_editing) {
      bloc.add(
        UpdateServiceProcessSubmitted(
          widget.existing!.id,
          UpdateServiceProcessRequest(
            targetName: target,
            serviceMethodId: _methodId,
            courtId: _courtId,
            scheduledAt: _scheduledAt,
            deadlineAt: _deadlineAt,
            processServerName: _optional(_server),
            recipientDetails: _optional(_recipient),
            notes: _optional(_notes),
          ),
        ),
      );
    } else {
      bloc.add(
        CreateServiceProcessSubmitted(
          CreateServiceProcessRequest(
            caseId: widget.caseId,
            targetName: target,
            serviceMethodId: _methodId!,
            courtId: _courtId,
            scheduledAt: _scheduledAt!,
            deadlineAt: _deadlineAt,
            processServerName: _optional(_server),
            recipientDetails: _optional(_recipient),
            notes: _optional(_notes),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final format = DateFormat.yMMMd().add_jm();
    final locale = Localizations.localeOf(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          context.tr(_editing ? 'edit_service_process' : 'new_service_process'),
        ),
      ),
      body: BlocListener<ServiceProcessFormBloc, ServiceProcessFormState>(
        listener: (context, state) {
          if (state is ServiceProcessFormSuccess) {
            context.pop(true);
          } else if (state is ServiceProcessFormReady &&
              state.submitError != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.submitError!)));
          }
        },
        child: BlocBuilder<ServiceProcessFormBloc, ServiceProcessFormState>(
          builder: (context, state) {
            if (state is ServiceProcessFormInitial ||
                state is ServiceProcessFormLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is! ServiceProcessFormReady) return const SizedBox();
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                children: [
                  AppTextField(
                    label: context.tr('service_target_name'),
                    controller: _target,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppDropdownField<String?>(
                    label: context.tr('service_method'),
                    value: _methodId,
                    items: state.methods.map((item) => item.id),
                    labelOf: (id) => state.methods
                        .firstWhere((item) => item.id == id)
                        .labelFor(locale),
                    onChanged: (value) => setState(() => _methodId = value),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppDropdownField<String?>(
                    label: context.tr('court'),
                    value: _courtId,
                    items: [null, ...state.courts.map((item) => item.id)],
                    labelOf: (id) => id == null
                        ? context.tr('none')
                        : state.courts.firstWhere((item) => item.id == id).name,
                    onChanged: (value) => setState(() => _courtId = value),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppDateField(
                    label: context.tr('scheduled_at'),
                    value: _scheduledAt,
                    dateFormat: format,
                    onTap: () => _pickDate(false),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppDateField(
                    label: context.tr('service_deadline'),
                    value: _deadlineAt,
                    dateFormat: format,
                    onTap: () => _pickDate(true),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppTextField(
                    label: context.tr('process_server_name'),
                    controller: _server,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppTextField(
                    label: context.tr('recipient_details'),
                    controller: _recipient,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppTextField(label: context.tr('notes'), controller: _notes),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    text: context.tr(
                      _editing ? 'save_changes' : 'create_service_process',
                    ),
                    isLoading: state.isSubmitting,
                    onPressed: _submit,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
