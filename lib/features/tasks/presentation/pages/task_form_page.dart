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
import '../../../cases/presentation/case_display_helpers.dart';
import '../../data/models/create_task_request.dart';
import '../../data/models/update_task_request.dart';
import '../../domain/entities/task_item.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_status.dart';
import '../bloc/task_form_bloc.dart';
import '../task_display_helpers.dart';

/// Shared Create/Edit screen — `existingTask == null` means create mode.
/// `assignedById` is always the current user (whoever is creating/editing
/// the task) — not shown as a field, since the natural default (the
/// person filling out this form) is the only sensible value here.
class TaskFormPage extends StatelessWidget {
  final TaskItem? existingTask;
  final String? fixedCaseId;

  const TaskFormPage({super.key, this.existingTask, this.fixedCaseId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<TaskFormBloc>()..add(LoadTaskFormReferenceDataRequested()),
      child: _TaskFormView(
        existingTask: existingTask,
        fixedCaseId: fixedCaseId,
      ),
    );
  }
}

class _TaskFormView extends StatefulWidget {
  final TaskItem? existingTask;
  final String? fixedCaseId;
  const _TaskFormView({this.existingTask, this.fixedCaseId});

  @override
  State<_TaskFormView> createState() => _TaskFormViewState();
}

class _TaskFormViewState extends State<_TaskFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TaskPriority _priority;
  late TaskStatus _status;
  String? _assignedToId;
  String? _caseId;
  DateTime? _dueDate;

  bool get _isEditMode => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    final t = widget.existingTask;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descriptionController = TextEditingController(text: t?.description ?? '');
    _priority = t?.priority ?? TaskPriority.normal;
    _status = t?.status ?? TaskStatus.newTask;
    _assignedToId = t?.assignedToId;
    _caseId = widget.fixedCaseId ?? t?.caseId;
    _dueDate = t?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final assignedToId = _assignedToId;
    if (assignedToId == null || _caseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('task_assignee_required'))),
      );
      return;
    }

    final bloc = context.read<TaskFormBloc>();
    if (_isEditMode) {
      final original = widget.existingTask!;
      final request = UpdateTaskRequest(
        status: _status != original.status ? _status : null,
      );
      bloc.add(UpdateTaskSubmitted(original.id, request));
    } else {
      final request = CreateTaskRequest(
        caseId: _caseId!,
        assignedToId: assignedToId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        priority: _priority,
        status: _status,
        dueDate: _dueDate,
      );
      bloc.add(CreateTaskSubmitted(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEditMode ? context.tr('edit_task') : context.tr('new_task'),
        ),
      ),
      body: SafeArea(
        child: BlocListener<TaskFormBloc, TaskFormState>(
          listener: (context, state) {
            if (state is TaskFormSuccess) {
              context.pop(true);
            } else if (state is TaskFormReady && state.submitError != null) {
              context.showErrorSnackBar(state.submitError);
            }
          },
          child: BlocBuilder<TaskFormBloc, TaskFormState>(
            builder: (context, state) {
              if (state is TaskFormLoading || state is TaskFormInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (state is! TaskFormReady) return const SizedBox();

              _assignedToId ??= state.users.isNotEmpty
                  ? state.users.first.id
                  : null;

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
                      AppDropdownField<String?>(
                        label: context.tr('assigned_to'),
                        value: _assignedToId,
                        items: state.users.map((u) => u.id),
                        labelOf: (id) =>
                            state.users.firstWhere((u) => u.id == id).fullName,
                        onChanged: (v) => setState(() => _assignedToId = v),
                      ),
                      if (state.users.isEmpty) ...[
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          context.tr('no_task_assignees'),
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.m),
                      if (widget.fixedCaseId == null) ...[
                        // Court number + year, not the internal generated
                        // `caseNumber`: every other Case picker in the app
                        // (Hearings, Meetings, Service, Finance, the Case
                        // list itself) identifies a filed Case by its
                        // judicial reference, and this dropdown was the one
                        // place still showing the opaque firm-local number.
                        AppDropdownField<String?>(
                          label: context.tr('case'),
                          value: _caseId,
                          items: state.cases.map((c) => c.id),
                          labelOf: (id) => legalCaseCourtReference(
                            state.cases.firstWhere((c) => c.id == id),
                          ),
                          onChanged: (v) => setState(() => _caseId = v),
                        ),
                        const SizedBox(height: AppSpacing.m),
                      ],
                      AppDropdownField<TaskPriority>(
                        label: context.tr('priority'),
                        value: _priority,
                        items: TaskPriority.values.where(
                          (p) => p != TaskPriority.unknown,
                        ),
                        labelOf: (p) => taskPriorityLabel(context, p),
                        onChanged: (v) => setState(() => _priority = v!),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppDropdownField<TaskStatus>(
                        label: context.tr('status'),
                        value: _status,
                        items: TaskStatus.values.where(
                          (s) =>
                              s == TaskStatus.newTask ||
                              s == TaskStatus.inProgress,
                        ),
                        labelOf: (s) => taskStatusLabel(context, s),
                        onChanged: (v) => setState(() => _status = v!),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppDateField(
                        label: context.tr('due_date'),
                        value: _dueDate,
                        dateFormat: dateFormat,
                        onTap: () => _pickDueDate(context),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        text: _isEditMode
                            ? context.tr('save_changes')
                            : context.tr('create_task'),
                        isLoading: state.isSubmitting,
                        onPressed: state.users.isEmpty
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
