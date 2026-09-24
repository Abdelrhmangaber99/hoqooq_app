import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum AppBadgeVariant {
  success, // emerald
  warning, // brass
  danger,  // rust
  neutral, // ink
}

class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;
  final IconData? icon;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.neutral,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;

    switch (variant) {
      case AppBadgeVariant.success:
        bgColor = AppColors.emerald100;
        textColor = AppColors.emerald700;
        break;
      case AppBadgeVariant.warning:
        bgColor = AppColors.brass50;
        textColor = AppColors.brass700;
        break;
      case AppBadgeVariant.danger:
        bgColor = AppColors.rust100;
        textColor = AppColors.rust600;
        break;
      case AppBadgeVariant.neutral:
        bgColor = AppColors.ink50;
        textColor = AppColors.ink600;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: textColor.withValues(alpha: 0.15),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
