import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dartz/dartz.dart' hide State;

import '../../../../core/auth/permission_check.dart';
import '../../../../core/auth/permission_codes.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/router/app_route_observer.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../cases/domain/entities/legal_case.dart';
import '../../../cases/presentation/case_display_helpers.dart';
import '../../domain/entities/task_item.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/repository/i_task_repository.dart';
import '../task_display_helpers.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with RouteAware {
  late ApiResult<List<TaskItem>> _load;

  /// `GET /cases`, so a card can show its Case's court number + year instead
  /// of the internal generated number its own payload carries.
  late final Future<Map<String, LegalCase>> _casesById = loadCasesById();

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    subscribeToAppRouteObserver(context, this);
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  /// The create/edit screen was closed: re-read the list, whichever way it
  /// was left, rather than only when it pops `true`.
  @override
  void didPopNext() {
    if (mounted) setState(_reload);
  }

  void _reload() => _load = getIt<ITaskRepository>().getTasks();

  Future<void> _openCreate() async {
    await context.push<bool>(AppRouter.tasksNew);
    if (mounted) setState(_reload);
  }

  /// Opens the read-only Task view, where the Complete / Cancel actions live.
  /// The Task is handed over as `extra` — this board already loaded it — and
  /// the board re-reads on return so a status changed there is reflected here.
  Future<void> _openDetails(TaskItem task) async {
    await context.push<bool>('${AppRouter.tasks}/${task.id}', extra: task);
    if (mounted) setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    if (!currentUserHasPerm(PermissionCodes.taskView)) {
      return Scaffold(
        body: ErrorView(
          message: context.tr('no_permission_message'),
          isForbidden: true,
          onRetry: () {},
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.paper,
      floatingActionButton: currentUserHasPerm(PermissionCodes.taskCreate)
          ? FloatingActionButton.extended(
              onPressed: _openCreate,
              backgroundColor: AppColors.brass500,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: Text(context.tr('new_task')),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('tasks'), style: AppTypography.h2),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<Either<Failure, List<TaskItem>>>(
                  future: _load,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return snapshot.data!.fold(
                      (failure) => ErrorView(
                        message: failure.message,
                        onRetry: () => setState(_reload),
                      ),
                      (tasks) => FutureBuilder<Map<String, LegalCase>>(
                        future: _casesById,
                        builder: (context, casesSnapshot) => _buildBoard(
                          casesSnapshot.data ?? const <String, LegalCase>{},
                          tasks,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoard(Map<String, LegalCase> casesById, List<TaskItem> tasks) {
    if (tasks.isEmpty) {
      return EmptyState(
        icon: Icons.task_alt_rounded,
        message: context.tr('no_tasks_found'),
        // Employees receive only tasks assigned to them or reachable through
        // a Case's `task.view` grant.
        hint: currentUserIsEmployee()
            ? context.tr('no_shared_records_hint')
            : null,
      );
    }
    // The deployed backend's Task status is exactly four values —
    // `TODO|IN_PROGRESS|COMPLETED|CANCELLED` (`CreateTaskDto` and
    // `TaskResponseDto`). This app still models the withdrawn `WAITING` value
    // so an older payload decodes rather than throwing, but it gets no column
    // of its own: a fifth column that can never fill is a visible mismatch
    // with the reference web app. Any such row folds into the first column
    // instead of disappearing.
    const columns = [
      TaskStatus.newTask,
      TaskStatus.inProgress,
      TaskStatus.completed,
      TaskStatus.cancelled,
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columns.map((status) {
          final items = tasks
              .where((task) => _columnFor(task.status) == status)
              .toList();
          return Container(
            width: 280,
            margin: const EdgeInsetsDirectional.only(end: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.paperSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        taskStatusLabel(context, status),
                        style: AppTypography.labelLarge,
                      ),
                    ),
                    _CountBadge(items.length),
                  ],
                ),
                const SizedBox(height: 10),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      context.tr('no_tasks_found'),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall,
                    ),
                  )
                else
                  ...items.map(
                    (task) => _TaskCard(
                      task,
                      casesById,
                      onTap: () => _openDetails(task),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  static TaskStatus _columnFor(TaskStatus status) =>
      status == TaskStatus.waiting ? TaskStatus.newTask : status;
}

class _TaskCard extends StatelessWidget {
  const _TaskCard(this.task, this.casesById, {required this.onTap});
  final TaskItem task;
  final Map<String, LegalCase> casesById;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 9),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title, style: AppTypography.labelLarge),
            if (task.caseSummary != null) ...[
              const SizedBox(height: 7),
              Text(
                courtReferenceForSummary(casesById, task.caseSummary),
                style: AppTypography.bodySmall.copyWith(
                  fontFamily: AppTypography.monoFont,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: taskPriorityColor(
                      task.priority,
                    ).withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    taskPriorityLabel(context, task.priority),
                    style: AppTypography.bodySmall.copyWith(
                      color: taskPriorityColor(task.priority),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (task.dueDate != null)
                  Text(
                    task.dueDate!.toLocal().toString().split(' ').first,
                    style: AppTypography.bodySmall.copyWith(
                      fontFamily: AppTypography.monoFont,
                    ),
                  ),
              ],
            ),
            if (task.assignedTo?.fullName.isNotEmpty == true) ...[
              const SizedBox(height: 9),
              Text(task.assignedTo!.fullName, style: AppTypography.bodySmall),
            ],
          ],
        ),
      ),
    ),
  );
}

class _CountBadge extends StatelessWidget {
  const _CountBadge(this.count);
  final int count;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text('$count', style: AppTypography.bodySmall),
  );
}
