import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';

class CaseDetailsPage extends StatelessWidget {
  const CaseDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('case_details')),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(context.tr('active'), style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCaseHeader(context),
            const SizedBox(height: AppSpacing.l),
            _buildTabs(context),
            const SizedBox(height: AppSpacing.l),
            _buildTimeline(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Criminal Defense',
                  style: AppTypography.labelMedium.copyWith(color: AppColors.primary, fontSize: 10),
                ),
              ),
              Text('#2026-CR-4471', style: AppTypography.bodySmall.copyWith(fontSize: 10)),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text('Hernandez v. State', style: AppTypography.h2),
          const SizedBox(height: 4),
          Text('Atty. James Reynolds', style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.l),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('3', context.tr('hearings')),
              _buildStat('7', context.tr('documents')),
              _buildStat('26', context.tr('days_open')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTypography.h3.copyWith(color: AppColors.primary)),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.bodySmall),
      ],
    );
  }

  Widget _buildTabs(BuildContext context) {
    final tabs = [context.tr('timeline'), context.tr('hearings'), context.tr('documents'), context.tr('notes')];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: tabs.map((tab) {
          final isSelected = tab == context.tr('timeline');
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.surfaceLight : Colors.transparent,
                borderRadius: AppRadius.small,
              ),
              child: Center(
                child: Text(
                  tab,
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeline( context) {
    final events = [
      {'title': 'Pre-trial hearing', 'date': 'Jul 16, 2026', 'isCompleted': false},
      {'title': 'Motion to suppress filed', 'date': 'Jul 10, 2026', 'isCompleted': true},
      {'title': 'Evidence review — 4 items', 'date': 'Jul 5, 2026', 'isCompleted': true},
      {'title': 'Initial consultation', 'date': 'Jun 28, 2026', 'isCompleted': true},
      {'title': 'Case opened', 'date': 'Jun 20, 2026', 'isCompleted': true},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isLast = index == events.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: (event['isCompleted'] as bool) ? AppColors.primary : AppColors.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: (event['isCompleted'] as bool)
                        ? const Icon(Icons.check, size: 14, color: Colors.black)
                        : Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: AppColors.surfaceLight,
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'] as String,
                    style: AppTypography.labelLarge.copyWith(
                      color: (event['isCompleted'] as bool) ? AppColors.textPrimary : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(event['date'] as String, style: AppTypography.bodySmall),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
