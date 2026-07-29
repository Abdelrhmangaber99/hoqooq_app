import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.m),
              _buildHeader(context),
              const SizedBox(height: AppSpacing.l),
              _buildFilters(context),
              const SizedBox(height: AppSpacing.m),
              _buildNotificationsList(context),
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
        Text(context.tr('alerts'), style: AppTypography.h1),
        Text(
          context.tr('mark_all_read'),
          style: AppTypography.labelMedium.copyWith(color: AppColors.primary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context) {
    final filters = [context.tr('view_all'), context.tr('hearings'), context.tr('deadline_alerts')];
    return Row(
      children: filters.map((filter) {
        final isSelected = filter == context.tr('view_all');
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (_) {},
            backgroundColor: AppColors.surface,
            selectedColor: AppColors.primary,
            labelStyle: AppTypography.labelMedium.copyWith(
              color: isSelected ? Colors.black : AppColors.textSecondary,
              fontSize: 12,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            side: BorderSide.none,
            showCheckmark: false,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotificationsList(BuildContext context) {
    final notifications = [
      {
        'title': context.tr('hearing_in_2_hours'),
        'subtitle': 'Hernandez v. State — District Court, Room 4',
        'time': '7:00 AM',
        'icon': Icons.gavel,
        'isUnread': true,
      },
      {
        'title': context.tr('filing_deadline_today'),
        'subtitle': 'TechCorp IP — Response brief due by 5:00 PM',
        'time': '6:30 AM',
        'icon': Icons.warning_amber_rounded,
        'isUnread': true,
        'iconColor': Colors.red,
      },
      {
        'title': context.tr('appointment_reminders'),
        'subtitle': 'Morrison Estate meeting at 11:30 AM',
        'time': context.tr('yesterday'),
        'icon': Icons.notifications_none,
        'isUnread': false,
      },
      {
        'title': context.tr('motion_deadline_tomorrow'),
        'subtitle': 'Hernandez — Motion to suppress response',
        'time': context.tr('yesterday'),
        'icon': Icons.warning_amber_rounded,
        'isUnread': false,
        'iconColor': Colors.red,
      },
      {
        'title': context.tr('new_message_from_client'),
        'subtitle': 'Patricia Morrison sent a message',
        'time': 'Jul 14',
        'icon': Icons.email_outlined,
        'isUnread': false,
      },
    ];

    return Expanded(
      child: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const Divider(color: AppColors.surfaceLight, height: 1),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        size: 20,
                        color: (item['iconColor'] as Color?) ?? AppColors.textHint,
                      ),
                    ),
                    if (item['isUnread'] as bool)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['title'] as String,
                            style: AppTypography.labelLarge.copyWith(
                              color: (item['isUnread'] as bool) ? AppColors.textPrimary : AppColors.textSecondary,
                            ),
                          ),
                          Text(item['time'] as String, style: AppTypography.bodySmall.copyWith(fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['subtitle'] as String,
                        style: AppTypography.bodySmall.copyWith(
                          color: (item['isUnread'] as bool) ? AppColors.textSecondary : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
