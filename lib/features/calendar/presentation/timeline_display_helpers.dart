import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../hearings/presentation/hearing_display_helpers.dart';
import '../../tasks/presentation/task_display_helpers.dart';
import '../domain/entities/timeline_item.dart';

DateTime? timelineItemDate(TimelineItem item) => switch (item) {
  TimelineEventItem(:final date) => date,
  TimelineHearingItem(:final date) => date,
  TimelineTaskItem(:final date) => date,
  TimelineUnknownItem() => null,
};

String timelineItemTitle(TimelineItem item) => switch (item) {
  TimelineEventItem(:final title) => title,
  TimelineHearingItem(:final title) => title,
  TimelineTaskItem(:final title) => title,
  TimelineUnknownItem(:final title) => title ?? '',
};

String timelineItemSubtitle(BuildContext context, TimelineItem item) =>
    switch (item) {
      TimelineEventItem() => context.tr('calendar'),
      TimelineHearingItem(:final status) => hearingStatusLabel(context, status),
      TimelineTaskItem(:final status) => taskStatusLabel(context, status),
      TimelineUnknownItem() => context.tr('unknown'),
    };

Color timelineItemColor(TimelineItem item) => switch (item) {
  TimelineEventItem() => AppColors.info,
  TimelineHearingItem(:final status) => hearingStatusColor(status),
  TimelineTaskItem(:final status) => taskStatusColor(status),
  TimelineUnknownItem() => AppColors.textHint,
};
