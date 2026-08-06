import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/entities/notification_type.dart';

IconData notificationTypeIcon(NotificationType type) {
  switch (type) {
    case NotificationType.hearingReminder:
      return Icons.gavel_outlined;
    case NotificationType.taskAssigned:
      return Icons.check_circle_outline;
    case NotificationType.invoiceDue:
      return Icons.receipt_long_outlined;
    case NotificationType.systemAlert:
      return Icons.warning_amber_rounded;
    case NotificationType.unknown:
      return Icons.notifications_none;
  }
}

Color notificationTypeColor(NotificationType type) {
  switch (type) {
    case NotificationType.hearingReminder:
      return AppColors.primary;
    case NotificationType.taskAssigned:
      return AppColors.info;
    case NotificationType.invoiceDue:
      return AppColors.warning;
    case NotificationType.systemAlert:
      return AppColors.error;
    case NotificationType.unknown:
      return AppColors.textHint;
  }
}
