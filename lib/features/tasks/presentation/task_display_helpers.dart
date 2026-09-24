import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/entities/task_priority.dart';
import '../domain/entities/task_status.dart';

String taskStatusLabel(BuildContext context, TaskStatus status) {
  switch (status) {
    case TaskStatus.newTask:
      return context.tr('new');
    case TaskStatus.inProgress:
      return context.tr('in_progress');
    case TaskStatus.waiting:
      return context.tr('waiting');
    case TaskStatus.completed:
      return context.tr('completed');
    case TaskStatus.cancelled:
      return context.tr('cancelled');
    case TaskStatus.unknown:
      return context.tr('unknown');
  }
}

Color taskStatusColor(TaskStatus status) {
  switch (status) {
    case TaskStatus.newTask:
      return AppColors.warning;
    case TaskStatus.inProgress:
      return AppColors.info;
    case TaskStatus.waiting:
      return AppColors.warning;
    case TaskStatus.completed:
      return AppColors.success;
    case TaskStatus.cancelled:
      return AppColors.textSecondary;
    case TaskStatus.unknown:
      return AppColors.textHint;
  }
}

String taskPriorityLabel(BuildContext context, TaskPriority priority) {
  switch (priority) {
    case TaskPriority.low:
      return context.tr('low');
    case TaskPriority.normal:
      return context.tr('normal');
    case TaskPriority.high:
      return context.tr('high');
    case TaskPriority.urgent:
      return context.tr('urgent');
    case TaskPriority.unknown:
      return context.tr('unknown');
  }
}

Color taskPriorityColor(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.low:
      return AppColors.info;
    case TaskPriority.normal:
      return AppColors.textSecondary;
    case TaskPriority.high:
      return AppColors.warning;
    case TaskPriority.urgent:
      return AppColors.error;
    case TaskPriority.unknown:
      return AppColors.textHint;
  }
}
