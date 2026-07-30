import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/entities/hearing_status.dart';

String hearingStatusLabel(BuildContext context, HearingStatus status) {
  switch (status) {
    case HearingStatus.scheduled:
      return context.tr('scheduled');
    case HearingStatus.completed:
      return context.tr('completed');
    case HearingStatus.adjourned:
      return context.tr('adjourned');
    case HearingStatus.cancelled:
      return context.tr('cancelled');
    case HearingStatus.unknown:
      return context.tr('unknown');
  }
}

Color hearingStatusColor(HearingStatus status) {
  switch (status) {
    case HearingStatus.scheduled:
      return AppColors.info;
    case HearingStatus.completed:
      return AppColors.success;
    case HearingStatus.adjourned:
      return AppColors.warning;
    case HearingStatus.cancelled:
      return AppColors.error;
    case HearingStatus.unknown:
      return AppColors.textHint;
  }
}
