import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';

/// Client Type is the free-form `clientType` string on a Case's
/// `clientSnapshot` (backend `CaseClientType` enum: `INDIVIDUAL` / `COMPANY`).
/// Mirrors the reference web app's `PARTY_TYPE` map (enums.js).
String clientTypeLabel(BuildContext context, String? clientType) {
  switch ((clientType ?? '').trim().toUpperCase()) {
    case 'COMPANY':
      return context.tr('company');
    case 'INDIVIDUAL':
      return context.tr('individual');
    default:
      final value = clientType?.trim();
      return (value == null || value.isEmpty) ? '—' : value;
  }
}

bool isCompanyClient(String? clientType) =>
    (clientType ?? '').trim().toUpperCase() == 'COMPANY';
