import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/entities/meeting_status.dart';

String meetingStatusLabel(BuildContext context, MeetingStatus status) =>
    context.tr(switch (status) {
      MeetingStatus.scheduled => 'scheduled',
      MeetingStatus.completed => 'completed',
      MeetingStatus.cancelled => 'cancelled',
      MeetingStatus.rescheduled => 'rescheduled',
      MeetingStatus.unknown => 'unknown',
    });
Color meetingStatusColor(MeetingStatus status) => switch (status) {
  MeetingStatus.completed => AppColors.success,
  MeetingStatus.cancelled => AppColors.error,
  MeetingStatus.rescheduled => AppColors.warning,
  MeetingStatus.scheduled || MeetingStatus.unknown => AppColors.primary,
};
