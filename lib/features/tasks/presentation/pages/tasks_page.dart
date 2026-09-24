import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dartz/dartz.dart' hide State;

import '../../../../core/auth/permission_check.dart';
import '../../../../core/auth/permission_codes.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../domain/entities/task_item.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/repository/i_task_repository.dart';
import '../task_display_helpers.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late ApiResult<List<TaskItem>> _load;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _load = getIt<ITaskRepository>().getTasks();

  Future<void> _openCreate() async {
    final created = await context.push<bool>(AppRouter.tasksNew);
    if (created == true && mounted) setState(_reload);
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
                      _buildBoard,
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

  Widget _buildBoard(List<TaskItem> tasks) {
    if (tasks.isEmpty) {
      return EmptyState(
        icon: Icons.task_alt_rounded,
        message: context.tr('no_tasks_found'),
      );
    }
    const columns = [
      TaskStatus.newTask,
      TaskStatus.inProgress,
      TaskStatus.waiting,
      TaskStatus.completed,
      TaskStatus.cancelled,
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columns.map((status) {
          final items = tasks.where((task) => task.status == status).toList();
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
                  ...items.map(_TaskCard.new),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard(this.task);
  final TaskItem task;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 9),
    child: Padding(
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(task.title, style: AppTypography.labelLarge),
          if (task.caseSummary?.caseNumber != null) ...[
            const SizedBox(height: 7),
            Text(
              task.caseSummary!.caseNumber,
              style: AppTypography.bodySmall.copyWith(
                fontFamily: AppTypography.monoFont,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
