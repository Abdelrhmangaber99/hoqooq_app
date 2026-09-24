import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';

/// Localized labels for the backend `SubscriptionStatus` enum —
/// PENDING/ACTIVE/EXPIRED/CANCELLED only; there is no SUSPENDED value
/// (the old automatic-suspension behavior was removed in v2). Shared by
/// every screen that displays a subscription status so the wording can
/// never drift between them.
String subscriptionStatusLabel(BuildContext context, String status) {
  return switch (status.toUpperCase()) {
    'PENDING' => context.tr('subscription_status_pending'),
    'ACTIVE' => context.tr('subscription_status_active'),
    'EXPIRED' => context.tr('subscription_status_expired'),
    'CANCELLED' => context.tr('subscription_status_cancelled'),
    _ => status,
  };
}
