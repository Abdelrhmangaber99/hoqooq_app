import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../authentication/presentation/bloc/session_cubit.dart';
import '../../../tasks/domain/entities/task_item.dart';
import '../../../tasks/presentation/task_display_helpers.dart';
import '../bloc/dashboard_bloc.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<DashboardBloc>()..add(FetchDashboardRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: AppSpacing.l),
                BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardLoading ||
                        state is DashboardInitial) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    } else if (state is DashboardError) {
                      return ErrorView(
                        message: state.message,
                        onRetry: () => context.read<DashboardBloc>().add(
                          FetchDashboardRequested(),
                        ),
                      );
                    } else if (state is DashboardLoaded) {
                      return _buildContent(context, state);
                    }
                    return const SizedBox();
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryCards(context, state),
        const SizedBox(height: AppSpacing.l),
        Text(context.tr('pending_tasks'), style: AppTypography.h3),
        const SizedBox(height: AppSpacing.m),
        _buildTaskList(context, state.pendingTasks),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final sessionState = getIt<SessionCubit>().state;
    final fullName = sessionState is SessionAuthenticated
        ? sessionState.user.fullName
        : '';
    final firstName = fullName.isNotEmpty ? fullName.split(' ').first : '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${context.tr('good_morning')}\n',
                style: AppTypography.h1,
              ),
              TextSpan(
                text: '$firstName.',
                style: AppTypography.h1.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => context.go(AppRouter.alerts),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.s),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.medium,
            ),
            child: const Icon(
              Icons.notifications_none,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context, DashboardLoaded state) {
    return Row(
      children: [
        _buildSummaryCard(
          '${state.metrics.totalActiveCases}',
          context.tr('active_cases'),
          Icons.business_center_outlined,
        ),
        const SizedBox(width: AppSpacing.m),
        _buildSummaryCard(
          '${state.metrics.pendingTasks}',
          context.tr('pending_tasks'),
          Icons.check_circle_outline,
        ),
        const SizedBox(width: AppSpacing.m),
        _buildSummaryCard(
          '${state.metrics.upcomingHearings}',
          context.tr('upcoming_hearings'),
          Icons.gavel_outlined,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.surfaceLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: AppSpacing.m),
            Text(value, style: AppTypography.h2),
            Text(label, style: AppTypography.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, List<TaskItem> tasks) {
    if (tasks.isEmpty) {
      return EmptyState(message: context.tr('no_tasks_found'));
    }
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
      ),
      child: Column(
        children: [
          for (var i = 0; i < tasks.length; i++) ...[
            if (i > 0) const Divider(color: AppColors.surfaceLight),
            _buildTaskItem(context, tasks[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, TaskItem task) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: AppTypography.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  task.dueDate != null
                      ? '${context.tr('due_date')}: ${task.dueDate!.toLocal().toString().split(' ').first}'
                      : context.tr('no_due_date'),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: taskPriorityColor(task.priority).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              taskPriorityLabel(context, task.priority),
              style: TextStyle(
                color: taskPriorityColor(task.priority),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
