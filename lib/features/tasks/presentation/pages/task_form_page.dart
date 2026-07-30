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

  const TaskFormPage({super.key, this.existingTask});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<TaskFormBloc>()..add(LoadTaskFormReferenceDataRequested()),
      child: _TaskFormView(existingTask: existingTask),
    );
  }
}

class _TaskFormView extends StatefulWidget {
  final TaskItem? existingTask;
  const _TaskFormView({this.existingTask});

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
    _status = t?.status ?? TaskStatus.pending;
    _assignedToId = t?.assignedToId;
    _caseId = t?.caseId;
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

  String? _currentUserId() {
    final sessionState = getIt<SessionCubit>().state;
    return sessionState is SessionAuthenticated ? sessionState.user.id : null;
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final assignedToId = _assignedToId;
    if (assignedToId == null) return;

    final bloc = context.read<TaskFormBloc>();
    if (_isEditMode) {
      final original = widget.existingTask!;
      final request = UpdateTaskRequest(
        caseId: _caseId != original.caseId ? _caseId : null,
        assignedToId: assignedToId != original.assignedToId
            ? assignedToId
            : null,
        title: _titleController.text.trim() != original.title
            ? _titleController.text.trim()
            : null,
        description:
            _descriptionController.text.trim() != (original.description ?? '')
            ? (_descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim())
            : null,
        priority: _priority != original.priority ? _priority : null,
        status: _status != original.status ? _status : null,
        dueDate: _dueDate != original.dueDate ? _dueDate : null,
      );
      bloc.add(UpdateTaskSubmitted(original.id, request));
    } else {
      final currentUserId = _currentUserId();
      if (currentUserId == null) return;
      final request = CreateTaskRequest(
        caseId: _caseId,
        assignedById: currentUserId,
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.submitError!)));
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

              _assignedToId ??= _currentUserId();

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
                      _buildDropdown<String?>(
                        label: context.tr('assigned_to'),
                        value: _assignedToId,
                        items: state.users.map((u) => u.id),
                        labelOf: (id) =>
                            state.users.firstWhere((u) => u.id == id).fullName,
                        onChanged: (v) => setState(() => _assignedToId = v),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      _buildDropdown<String?>(
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
                      _buildDropdown<TaskPriority>(
                        label: context.tr('priority'),
                        value: _priority,
                        items: TaskPriority.values.where(
                          (p) => p != TaskPriority.unknown,
                        ),
                        labelOf: (p) => taskPriorityLabel(context, p),
                        onChanged: (v) => setState(() => _priority = v!),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      _buildDropdown<TaskStatus>(
                        label: context.tr('status'),
                        value: _status,
                        items: TaskStatus.values.where(
                          (s) => s != TaskStatus.unknown,
                        ),
                        labelOf: (s) => taskStatusLabel(context, s),
                        onChanged: (v) => setState(() => _status = v!),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      _buildDateField(
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
