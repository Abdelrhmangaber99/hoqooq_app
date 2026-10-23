import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Shown when a list screen's fetch succeeds but returns zero results,
/// per spec §5 ("show EmptyState when zero results").
class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  /// Optional second line explaining *why* the list is empty when that is not
  /// obvious. An Employee's Cases/Tasks/Hearings lists are filtered
  /// server-side to what they hold a per-Case grant for or are assigned to
  /// (`CasesService.findAll` / `TasksService.findAll` /
  /// `HearingsService.findAll`), so "No cases found" on its own reads as a
  /// broken screen rather than as access that has not been granted yet.
  final String? hint;

  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final hintText = hint;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textHint),
            const SizedBox(height: AppSpacing.m),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (hintText != null && hintText.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s),
              Text(
                hintText,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
