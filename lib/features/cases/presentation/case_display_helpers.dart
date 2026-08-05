import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/entities/case_access_level.dart';
import '../domain/entities/case_priority.dart';
import '../domain/entities/case_status.dart';

String caseStatusLabel(BuildContext context, CaseStatus status) {
  switch (status) {
    case CaseStatus.draft:
      return context.tr('draft');
    case CaseStatus.active:
      return context.tr('active');
    case CaseStatus.suspended:
      return context.tr('suspended');
    case CaseStatus.closed:
      return context.tr('closed');
    case CaseStatus.archived:
      return context.tr('archived');
    case CaseStatus.unknown:
      return context.tr('unknown');
  }
}

Color caseStatusColor(CaseStatus status) {
  switch (status) {
    case CaseStatus.draft:
      return AppColors.textHint;
    case CaseStatus.active:
      return AppColors.success;
    case CaseStatus.suspended:
      return AppColors.warning;
    case CaseStatus.closed:
      return AppColors.textSecondary;
    case CaseStatus.archived:
      return AppColors.warning;
    case CaseStatus.unknown:
      return AppColors.textHint;
  }
}

String casePriorityLabel(BuildContext context, CasePriority priority) {
  switch (priority) {
    case CasePriority.low:
      return context.tr('low');
    case CasePriority.normal:
      return context.tr('normal');
    case CasePriority.high:
      return context.tr('high');
    case CasePriority.urgent:
      return context.tr('urgent');
    case CasePriority.unknown:
      return context.tr('unknown');
  }
}

Color casePriorityColor(CasePriority priority) {
  switch (priority) {
    case CasePriority.low:
      return AppColors.info;
    case CasePriority.normal:
      return AppColors.textSecondary;
    case CasePriority.high:
      return AppColors.warning;
    case CasePriority.urgent:
      return AppColors.error;
    case CasePriority.unknown:
      return AppColors.textHint;
  }
}

String caseAccessLevelLabel(BuildContext context, CaseAccessLevel level) {
  switch (level) {
    case CaseAccessLevel.fullAccess:
      return context.tr('full_access');
    case CaseAccessLevel.readOnly:
      return context.tr('read_only');
    case CaseAccessLevel.uploadDocuments:
      return context.tr('upload_documents');
    case CaseAccessLevel.assignHearing:
      return context.tr('assign_hearing');
    case CaseAccessLevel.unknown:
      return context.tr('unknown');
  }
}

Color caseAccessLevelColor(CaseAccessLevel level) {
  switch (level) {
    case CaseAccessLevel.fullAccess:
      return AppColors.success;
    case CaseAccessLevel.readOnly:
      return AppColors.textSecondary;
    case CaseAccessLevel.uploadDocuments:
      return AppColors.info;
    case CaseAccessLevel.assignHearing:
      return AppColors.warning;
    case CaseAccessLevel.unknown:
      return AppColors.textHint;
  }
}
