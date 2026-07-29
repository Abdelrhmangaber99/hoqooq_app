import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: AppSpacing.l),
              _buildSummaryCards(context),
              const SizedBox(height: AppSpacing.l),
              _buildSectionHeader(context, context.tr('todays_schedule'), showViewAll: true),
              const SizedBox(height: AppSpacing.m),
              _buildScheduleList(context),
              const SizedBox(height: AppSpacing.l),
              _buildSectionHeader(context, context.tr('priority_tasks'), badge: '3 pending'),
              const SizedBox(height: AppSpacing.m),
              _buildTaskList(),
              const SizedBox(height: AppSpacing.l),
              _buildSectionHeader(context, context.tr('recent_clients'), showViewAll: true),
              const SizedBox(height: AppSpacing.m),
              _buildClientsList(context),
              const SizedBox(height: AppSpacing.xxl), // Space for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WEDNESDAY, JULY 16',
              style: AppTypography.labelMedium.copyWith(letterSpacing: 1.5),
            ),
            const SizedBox(height: AppSpacing.s),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${context.tr('good_morning')}\n', style: AppTypography.h1),
                  TextSpan(text: '${context.tr('james_reynolds').split(' ')[0]}.', style: AppTypography.h1.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => context.go(AppRouter.alerts),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.s),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.medium,
            ),
            child: Stack(
              children: [
                const Icon(Icons.notifications_none, color: AppColors.textPrimary),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return Row(
      children: [
        _buildSummaryCard('3', context.tr('appts'), Icons.calendar_today_outlined),
        const SizedBox(width: AppSpacing.m),
        _buildSummaryCard('14', context.tr('cases'), Icons.business_center_outlined),
        const SizedBox(width: AppSpacing.m),
        _buildSummaryCard('5', context.tr('tasks'), Icons.check_circle_outline),
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

  Widget _buildSectionHeader(BuildContext context, String title, {bool showViewAll = false, String? badge}) {
    return Row(
      children: [
        Text(title, style: AppTypography.h3),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badge,
              style: AppTypography.labelMedium.copyWith(color: AppColors.primary, fontSize: 10),
            ),
          ),
        ],
        const Spacer(),
        if (showViewAll)
          Text(
            context.tr('view_all'),
            style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
          ),
      ],
    );
  }

  Widget _buildScheduleList(BuildContext context) {
    return Column(
      children: [
        _buildScheduleItem(
          context.tr('case_hernandez_v_state'),
          context.tr('carlos_hernandez'),
          '09:00 AM · 1h',
          context.tr('district_court'),
          context.tr('hearing'),
          Colors.green.withValues(alpha: 0.2),
        ),
        const SizedBox(height: AppSpacing.m),
        _buildScheduleItem(
          context.tr('case_morrison_estate'),
          context.tr('patricia_morrison'),
          '11:30 AM · 45m',
          context.tr('office'),
          context.tr('client_meeting'),
          Colors.purple.withValues(alpha: 0.2),
        ),
        const SizedBox(height: AppSpacing.m),
        _buildScheduleItem(
          context.tr('case_techcorp_ip'),
          context.tr('techcorp_inc'),
          '02:00 PM · 2h',
          context.tr('federal_court'),
          context.tr('deposition'),
          Colors.orange.withValues(alpha: 0.2),
        ),
      ],
    );
  }

  Widget _buildScheduleItem(
    String title,
    String subtitle,
    String time,
    String location,
    String type,
    Color typeColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
        border: Border(left: BorderSide(color: typeColor.withValues(alpha: 0.8), width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.labelLarge),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  type,
                  style: AppTypography.labelMedium.copyWith(fontSize: 10, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTypography.bodySmall),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(time, style: AppTypography.bodySmall),
              const SizedBox(width: 12),
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(location, style: AppTypography.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
      ),
      child: Column(
        children: [
          _buildTaskItem('File motion for Hernandez case', 'Today', isOverdue: true),
          const Divider(color: AppColors.surfaceLight),
          _buildTaskItem('Review Morrison estate documents', 'Today', isCompleted: true),
          const Divider(color: AppColors.surfaceLight),
          _buildTaskItem('Prepare TechCorp IP brief', 'Tomorrow'),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String title, String dueDate, {bool isOverdue = false, bool isCompleted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isCompleted ? AppColors.primary : AppColors.textHint),
            ),
            child: isCompleted ? const Icon(Icons.check, size: 16, color: Colors.black) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? AppColors.textHint : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (isOverdue) ...[
                      const Icon(Icons.warning_amber_rounded, size: 12, color: Colors.red),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      dueDate,
                      style: AppTypography.bodySmall.copyWith(
                        color: isOverdue ? Colors.red : AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientsList(BuildContext context) {
    final clients = [
      {'name': context.tr('carlos_hernandez').split(' ')[0], 'initials': 'CH'},
      {'name': context.tr('patricia_morrison').split(' ')[0], 'initials': 'PM'},
      {'name': context.tr('techcorp_inc').split(' ')[0], 'initials': 'TI'},
      {'name': context.tr('sarah_chen').split(' ')[0], 'initials': 'SC'},
      {'name': context.tr('david_park').split(' ')[0], 'initials': 'DP'},
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: clients.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.m),
        itemBuilder: (context, index) {
          final client = clients[index];
          return Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    client['initials']!,
                    style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(client['name']!, style: AppTypography.bodySmall),
            ],
          );
        },
      ),
    );
  }
}
