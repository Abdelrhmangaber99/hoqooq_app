import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/permission_check.dart';
import '../../../../core/auth/permission_codes.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/error_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../di/injection.dart';
import '../../../cases/domain/entities/legal_case.dart';
import '../../../cases/presentation/case_display_helpers.dart';
import '../../data/models/update_task_request.dart';
import '../../domain/entities/task_item.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/repository/i_task_repository.dart';
import '../task_display_helpers.dart';

/// Read-only Task view with the two lifecycle actions the deployed backend
/// exposes as dedicated routes:
///
/// * `PATCH /tasks/{id}/complete` — requires `task.complete`; the backend
///   mandates a non-empty `completionNote` (`CompleteTaskDto`), which is why
///   completing reveals a note field instead of acting immediately.
/// * `DELETE /tasks/{id}` — also requires `task.complete`; it sets
///   `status = CANCELLED` and keeps the row, matching every other "delete" in
///   this API (BR-016).
///
/// `PATCH /tasks/{id}` (requires `task.update`) is the only way to move a task
/// to a non-final status, and the backend rejects `COMPLETED` through it
/// outright ("Use the dedicated task completion endpoint") — hence the status
/// chips offer only `TODO`/`IN_PROGRESS` and completion is its own action.
///
/// Mirrors the reference web/desktop app's Task dialog, which offers the same
/// three affordances in the same conditional shape. Both an Employee holding
/// the codes and a Firm Admin see them — `currentUserHasPerm` treats a
/// Firm Admin as holding every non-platform code, which is exactly how the
/// backend's `PermissionsGuard` treats them too.
class TaskDetailsPage extends StatefulWidget {
  const TaskDetailsPage({super.key, required this.task});

  final TaskItem task;

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  /// Local copy so a completed/cancelled Task re-renders with its new status
  /// without another round trip. The list this page was opened from refreshes
  /// itself on pop (`TasksPage.didPopNext`), so nothing else needs telling.
  late TaskItem _task = widget.task;

  /// `GET /cases`, cached app-wide, so the Case row can show the judicial
  /// reference (court number / year) rather than the internal generated
  /// number the nested brief carries.
  late final Future<Map<String, LegalCase>> _casesById = loadCasesById();

  final _noteController = TextEditingController();

  bool _isCompleting = false;
  bool _isSubmitting = false;
  String? _actionError;

  bool get _isFinal =>
      _task.status == TaskStatus.completed ||
      _task.status == TaskStatus.cancelled;

  bool get _canUpdate => currentUserHasPerm(PermissionCodes.taskUpdate);
  bool get _canComplete => currentUserHasPerm(PermissionCodes.taskComplete);

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _applyUpdated(TaskItem updated) {
    setState(() {
      _task = updated;
      _isSubmitting = false;
      _isCompleting = false;
      _actionError = null;
    });
    _noteController.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.tr('changes_saved'))));
  }

  void _applyFailure(String message) {
    setState(() {
      _isSubmitting = false;
      _actionError = message;
    });
    context.showErrorSnackBar(message);
  }

  Future<void> _changeStatus(TaskStatus status) async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _actionError = null;
    });
    final result = await getIt<ITaskRepository>().updateTask(
      _task.id,
      UpdateTaskRequest(status: status),
    );
    if (!mounted) return;
    result.fold((failure) => _applyFailure(failure.message), _applyUpdated);
  }

  Future<void> _complete() async {
    final note = _noteController.text.trim();
    // `CompleteTaskDto.completionNote` is required server-side; submitting an
    // empty one would come back as a 400 rather than a useful message.
    if (note.isEmpty || _isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _actionError = null;
    });
    final result = await getIt<ITaskRepository>().completeTask(_task.id, note);
    if (!mounted) return;
    result.fold((failure) => _applyFailure(failure.message), _applyUpdated);
  }

  Future<void> _cancel() async {
    if (_isSubmitting) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('cancel_task')),
        content: Text(context.tr('cancel_task_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.tr('confirm')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _isSubmitting = true;
      _actionError = null;
    });
    final result = await getIt<ITaskRepository>().cancelTask(_task.id);
    if (!mounted) return;
    result.fold(
      (failure) => _applyFailure(failure.message),
      // `DELETE /tasks/{id}` answers 200 with no body, so the refreshed Task
      // comes from the local status flip rather than a response payload.
      (_) => _applyUpdated(
        _task.copyWith(
          status: TaskStatus.cancelled,
          completedAt: DateTime.now(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.paper,
    appBar: AppBar(title: Text(context.tr('task_details'))),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: [
          Text(_task.title, style: AppTypography.h3),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              _Badge(
                label: taskStatusLabel(context, _task.status),
                color: taskStatusColor(_task.status),
              ),
              _Badge(
                label: taskPriorityLabel(context, _task.priority),
                color: taskPriorityColor(_task.priority),
              ),
            ],
          ),
          if (_task.description != null && _task.description!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.m),
            Text(_task.description!, style: AppTypography.bodyMedium),
          ],
          const SizedBox(height: AppSpacing.l),
          FutureBuilder<Map<String, LegalCase>>(
            future: _casesById,
            builder: (context, snapshot) => _InfoRow(
              label: context.tr('case'),
              value: courtReferenceForSummary(
                snapshot.data ?? const <String, LegalCase>{},
                _task.caseSummary,
              ),
              mono: true,
            ),
          ),
          _InfoRow(
            label: context.tr('assigned_to'),
            value: _task.assignedTo?.fullName ?? '—',
          ),
          if (_task.dueDate != null)
            _InfoRow(
              label: context.tr('due_date'),
              value: DateFormat.yMMMd().format(_task.dueDate!.toLocal()),
              mono: true,
            ),
          if (_task.completionNote != null && _task.completionNote!.isNotEmpty)
            _InfoRow(
              label: context.tr('completion_note'),
              value: _task.completionNote!,
            ),
          if (_actionError != null) ...[
            const SizedBox(height: AppSpacing.m),
            Text(
              localizedErrorMessage(context, _actionError),
              style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            ),
          ],
          if (!_isFinal && (_canUpdate || _canComplete)) ...[
            const SizedBox(height: AppSpacing.l),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.m),
            ..._buildActions(context),
          ],
        ],
      ),
    ),
  );

  List<Widget> _buildActions(BuildContext context) => [
    if (_canUpdate && !_isCompleting) ...[
      Text(context.tr('change_status'), style: AppTypography.labelMedium),
      const SizedBox(height: AppSpacing.s),
      Wrap(
        spacing: AppSpacing.s,
        runSpacing: AppSpacing.s,
        children: [TaskStatus.newTask, TaskStatus.inProgress]
            .where((status) => status != _task.status)
            .map(
              (status) => ActionChip(
                label: Text(taskStatusLabel(context, status)),
                onPressed: _isSubmitting ? null : () => _changeStatus(status),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: AppSpacing.m),
    ],
    if (_canComplete && !_isCompleting)
      Row(
        children: [
          Expanded(
            child: AppButton(
              text: context.tr('complete_task'),
              icon: Icons.task_alt,
              isLoading: _isSubmitting,
              onPressed: () => setState(() => _isCompleting = true),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: AppButton(
              text: context.tr('cancel_task'),
              icon: Icons.cancel_outlined,
              style: AppButtonStyle.outline,
              onPressed: _isSubmitting ? null : _cancel,
            ),
          ),
        ],
      ),
    if (_canComplete && _isCompleting) ...[
      AppTextField(
        label: context.tr('completion_note'),
        controller: _noteController,
        maxLines: 3,
      ),
      const SizedBox(height: AppSpacing.m),
      Row(
        children: [
          Expanded(
            // `CompleteTaskDto.completionNote` is required server-side, so an
            // empty note is not a submittable request at all. The reference
            // desktop app disables its own submit until the field has
            // content; mirroring that here replaces a tap that silently did
            // nothing (`_complete()` returned early, so the button looked
            // broken) with an obviously-disabled one.
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _noteController,
              builder: (context, value, _) => AppButton(
                text: context.tr('confirm'),
                isLoading: _isSubmitting,
                onPressed: value.text.trim().isEmpty ? null : _complete,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: AppButton(
              text: context.tr('cancel'),
              style: AppButtonStyle.secondary,
              onPressed: _isSubmitting
                  ? null
                  : () => setState(() => _isCompleting = false),
            ),
          ),
        ],
      ),
    ],
  ];
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: AppTypography.bodySmall.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.mono = false});

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.s),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontFamily: mono ? AppTypography.monoFont : null,
          ),
        ),
      ],
    ),
  );
}
