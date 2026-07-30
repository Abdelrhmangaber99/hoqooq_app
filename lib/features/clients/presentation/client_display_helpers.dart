import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/entities/client_status.dart';
import '../domain/entities/client_type.dart';

String clientStatusLabel(BuildContext context, ClientStatus status) {
  switch (status) {
    case ClientStatus.active:
      return context.tr('active');
    case ClientStatus.archived:
      return context.tr('archived');
    case ClientStatus.inactive:
      return context.tr('inactive');
    case ClientStatus.unknown:
      return context.tr('unknown');
  }
}

Color clientStatusColor(ClientStatus status) {
  switch (status) {
    case ClientStatus.active:
      return AppColors.success;
    case ClientStatus.archived:
      return AppColors.warning;
    case ClientStatus.inactive:
      return AppColors.textHint;
    case ClientStatus.unknown:
      return AppColors.textHint;
  }
}

String clientTypeLabel(BuildContext context, ClientType type) {
  switch (type) {
    case ClientType.individual:
      return context.tr('individual');
    case ClientType.company:
      return context.tr('company');
    case ClientType.unknown:
      return context.tr('unknown');
  }
}
