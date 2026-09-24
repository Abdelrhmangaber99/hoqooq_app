import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../hearings/presentation/hearing_display_helpers.dart';
import '../../tasks/presentation/task_display_helpers.dart';
import '../../meetings/presentation/meeting_display_helpers.dart';
import '../../service_of_process/presentation/service_process_display_helpers.dart';
import '../domain/entities/timeline_item.dart';

DateTime? timelineItemDate(TimelineItem item) => switch (item) {
  TimelineEventItem(:final date) => date,
  TimelineHearingItem(:final date) => date,
  TimelineServiceItem(:final date) => date,
  TimelineMeetingItem(:final date) => date,
  TimelineTaskItem(:final date) => date,
  TimelineUnknownItem() => null,
};

String timelineItemTitle(TimelineItem item) => switch (item) {
  TimelineEventItem(:final title) => title,
  TimelineHearingItem(:final title) => title,
  TimelineServiceItem(:final title) => title,
  TimelineMeetingItem(:final title) => title,
  TimelineTaskItem(:final title) => title,
  TimelineUnknownItem(:final title) => title ?? '',
};

String timelineItemSubtitle(BuildContext context, TimelineItem item) =>
    switch (item) {
      TimelineEventItem() => context.tr('calendar'),
      TimelineHearingItem(:final status) => hearingStatusLabel(context, status),
      TimelineServiceItem(:final status) => serviceStatusLabel(context, status),
      TimelineMeetingItem(:final status) => meetingStatusLabel(context, status),
      TimelineTaskItem(:final status) => taskStatusLabel(context, status),
      TimelineUnknownItem() => context.tr('unknown'),
    };

Color timelineItemColor(TimelineItem item) => switch (item) {
  TimelineEventItem() => AppColors.info,
  TimelineHearingItem(:final status) => hearingStatusColor(status),
  TimelineServiceItem(:final status) => serviceStatusColor(status),
  TimelineMeetingItem(:final status) => meetingStatusColor(status),
  TimelineTaskItem(:final status) => taskStatusColor(status),
  TimelineUnknownItem() => AppColors.textHint,
};
