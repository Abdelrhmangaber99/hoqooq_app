import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/entities/service_status.dart';

String serviceStatusLabel(BuildContext context, ServiceStatus status) =>
    context.tr(switch (status) {
      ServiceStatus.scheduled => 'scheduled',
      ServiceStatus.completed => 'completed',
      ServiceStatus.failed => 'failed',
      ServiceStatus.rescheduled => 'rescheduled',
      ServiceStatus.cancelled => 'cancelled',
      ServiceStatus.unknown => 'unknown',
    });

Color serviceStatusColor(ServiceStatus status) => switch (status) {
  ServiceStatus.completed => AppColors.success,
  ServiceStatus.failed || ServiceStatus.cancelled => AppColors.error,
  ServiceStatus.rescheduled => AppColors.warning,
  ServiceStatus.scheduled || ServiceStatus.unknown => AppColors.primary,
};
