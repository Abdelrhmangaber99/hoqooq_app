import 'package:flutter/material.dart';

import 'app_localizations.dart';

/// Translates the error text that reaches the UI, so a user running the app
/// in Arabic does not get an English sentence back from the app itself.
///
/// Two kinds of message end up in an error state:
///
/// 1. Text this app authors — the default `Failure` messages in
///    `core/errors/failures.dart` and the fallbacks in
///    `core/network/dio_error_mapper.dart`. These are compile-time constants,
///    so they map back to a localization key and translate exactly.
/// 2. Text the backend authors (`{success, statusCode, message, ...}`). Only
///    its generic, fixed sentences are mapped (a rejected request, an expired
///    token, an unprocessable entity). A dynamic validation sentence such as
///    "caseNumber is required" has no client-side translation and is passed
///    through unchanged rather than replaced by a vaguer generic sentence —
///    losing the field name would make the error useless.
///
/// Unknown text is returned untouched, and a key the active locale has no
/// translation for also falls back to the untouched text. English behavior is
/// therefore byte-identical to before, and no message is ever swallowed.
String localizedErrorMessage(BuildContext context, String? message) {
  final text = message?.trim() ?? '';
  if (text.isEmpty) return context.tr('error_generic');

  final exact = _sourceKeys[text];
  if (exact != null) {
    final translated = context.tr(exact);
    // `tr()` returns the key itself when the locale has no entry (or when no
    // AppLocalizations is mounted, e.g. a bare MaterialApp in a widget test).
    // Fall back to the original text rather than showing a raw key.
    return translated == exact ? text : translated;
  }

  final prefix = _prefixKeys.entries.firstWhere(
    (entry) => text.startsWith(entry.key),
    orElse: () => const MapEntry('', ''),
  );
  if (prefix.key.isNotEmpty) {
    final suffix = text.substring(prefix.key.length).trim();
    final translated = context.tr(prefix.value);
    final label = translated == prefix.value ? prefix.key.trim() : translated;
    return suffix.isEmpty ? label : '$label $suffix';
  }

  // The backend runs `class-validator` with its stock English messages
  // (`email must be an email`, `password should not be empty`, …). They are
  // formulaic enough to translate as a class, so a rejected form shows a
  // sentence in the active locale instead of the raw library default.
  for (final rule in _patternKeys) {
    if (!rule.pattern.hasMatch(text)) continue;
    final translated = context.tr(rule.key);
    return translated == rule.key ? text : translated;
  }

  return text;
}

/// Everything the app itself can put in a `Failure.message`, plus the
/// backend's fixed generic sentences. Values are the localization keys added
/// alongside this file; the English value of each key is identical to the
/// source string, so English output is unchanged.
const Map<String, String> _sourceKeys = {
  // core/errors/failures.dart
  'Server error occurred': 'error_server',
  'Cache error occurred': 'error_cache',
  'No internet connection': 'error_network',
  'Unauthorized access': 'error_unauthorized',
  "You don't have permission to do this": 'error_forbidden',
  'Subscription inactive or expired': 'error_subscription_inactive',
  // core/network/dio_error_mapper.dart
  'Invalid request': 'error_invalid_request',
  // Backend generic responses (HttpExceptionFilter message strings).
  'Invalid credentials': 'error_invalid_credentials',
  'Token expired': 'error_session_expired',
  'Insufficient permissions': 'error_insufficient_permissions',
  'Not found': 'error_not_found',
  'Unprocessable entity': 'error_unprocessable',
  'Internal server error': 'error_server',
  'Too many requests': 'error_too_many_requests',
  // The permissions guard's escalation/tenancy refusals. These are what a
  // firm account actually sees when it reaches a platform-only route, so they
  // must translate rather than leak the backend's English sentence.
  'Platform permission required': 'error_platform_permission_required',
  'Platform accounts cannot access firm legal resources':
      'error_platform_accounts_blocked',
  'User not authenticated': 'error_unauthorized',
  // Identity strategy rejections (401).
  'Account is inactive': 'error_account_inactive',
  'Firm is inactive': 'error_firm_inactive',
  'Invalid access token': 'error_unauthorized',
  // Employee/account lifecycle and tenancy rules.
  'A Firm account is required to onboard Employees':
      'error_firm_account_required',
  'A Firm account is required to change an Employee status':
      'error_firm_account_required',
  'The Super Admin status cannot be changed through this endpoint':
      'error_super_admin_status_locked',
  'You cannot access employees of another firm': 'error_own_firm_only',
  // Permission delegation rules.
  'You can only manage permissions for accounts in your own firm':
      'error_own_firm_only',
  'Invalid permission grantor': 'error_own_firm_only',
  'Platform permissions cannot be granted to an Employee':
      'error_platform_permissions_not_grantable',
  'Platform permissions cannot be granted to a Firm Admin':
      'error_platform_permissions_not_grantable',
  'Platform-level permissions cannot be granted to a firm account':
      'error_platform_permissions_not_grantable',
  'Cannot grant a permission the creator does not hold':
      'error_cannot_grant_unheld_permission',
  'You cannot grant permissions you do not hold':
      'error_cannot_grant_unheld_permission',
  'Only administrators can view the permission catalog': 'error_forbidden',
  'Employee permission management is required': 'error_forbidden',
  'This endpoint only manages Employee permissions': 'error_forbidden',
  // Lawyer specialization validation.
  'Only Lawyers may have Case Type specializations':
      'error_lawyer_specializations_only',
  'A lawyer must have at least one specialization':
      'error_lawyer_specialization_required',
  'One or more specializations are invalid': 'error_invalid_specializations',
  'One or more permission codes are invalid': 'error_invalid_permissions',
  'One or more permission keys are invalid': 'error_invalid_permissions',
  // Identity service: login, MFA, invitations and password recovery. These
  // are the sentences a signed-out user can actually hit, so an unmapped one
  // shows English on the login screen in Arabic mode.
  'Invalid credentials or MFA code': 'error_invalid_credentials_or_mfa',
  'Invalid MFA code': 'error_invalid_mfa_code',
  'Invalid MFA configuration': 'error_invalid_mfa_code',
  'MFA setup and verification are required': 'error_mfa_required',
  'Incorrect old password': 'error_incorrect_old_password',
  'Invitation was already used': 'error_invitation_already_used',
  'Invalid or expired activation token': 'error_invalid_activation_link',
  'Invalid or expired reset token': 'error_invalid_reset_link',
  'Reset token was already used': 'error_invalid_reset_link',
  'Invalid or expired refresh token': 'error_session_expired',
  'Firm Admin email already exists': 'error_email_already_exists',
  'Firm account required': 'error_firm_account_required',
  // Permission / assignment delegation rules.
  'You cannot change your own permissions':
      'error_cannot_change_own_permissions',
  'You cannot delegate capabilities you do not hold':
      'error_cannot_grant_unheld_permission',
  'Assignee is invalid or inactive': 'error_assignee_inactive',
  'Task assignee is invalid or inactive': 'error_assignee_inactive',
  'Target Employee is invalid or inactive': 'error_assignee_inactive',
  // Platform-admin action fallbacks authored in this app
  // (`firm_details_page.dart`), shown through the same snack-bar path.
  'Could not change firm status.': 'error_firm_status_change_failed',
  'Could not change account status.': 'error_account_status_change_failed',
  'Could not change subscription status.': 'error_subscription_change_failed',
  'Could not update the plan.': 'error_plan_update_failed',
};

/// `class-validator`'s built-in messages, which the backend returns verbatim on
/// a rejected body. Matched after the exact map and before the dynamic prefix
/// map; the whole message is replaced (there is no field name worth keeping
/// — the localized sentence already names the problem).
final List<({RegExp pattern, String key})> _patternKeys = [
  (pattern: RegExp(r'^\S+ must be an email$'), key: 'invalid_email'),
  (pattern: RegExp(r'^\S+ should not be empty$'), key: 'field_required'),
  (
    pattern: RegExp(r'^\S+ must be longer than or equal to \d+ characters$'),
    key: 'error_value_too_short',
  ),
  (
    pattern: RegExp(r'^\S+ must be shorter than or equal to \d+ characters$'),
    key: 'error_value_too_long',
  ),
  (pattern: RegExp(r'^\S+ must be a string$'), key: 'error_invalid_request'),
  (pattern: RegExp(r'^\S+ must be a UUID$'), key: 'error_invalid_request'),
  (pattern: RegExp(r'^\S+ must be a number.*$'), key: 'error_invalid_request'),
  (pattern: RegExp(r'^\S+ must be a boolean.*$'), key: 'error_invalid_request'),
  (
    pattern: RegExp(r'^\S+ must be one of the following values:.*$'),
    key: 'error_invalid_request',
  ),
  (
    pattern: RegExp(r'^property \S+ should not exist$'),
    key: 'error_unexpected_field',
  ),
];

/// Backend messages that carry a variable suffix, e.g. the permissions guard's
/// `Missing permission: cases.delete`.
const Map<String, String> _prefixKeys = {
  'Missing permission:': 'error_missing_permission',
  // Variable-suffix backend sentences where appending the suffix still reads
  // as a sentence (e.g. "This employee still has open assignments: 1 …").
  'Employee has open assignments': 'error_employee_open_assignments',
  'Subscription not found for tenant': 'error_subscription_not_found',
};

/// Resolves a value that may be either a localization key (`full_name_required`)
/// or an already-worded message (`No internet connection`) into the active
/// locale.
///
/// Some failure states deliberately carry a stable key so the UI can pick the
/// right copy; others pass a backend sentence straight through. This lets a
/// single display site handle both without knowing which it received.
String localizedErrorKeyOrMessage(BuildContext context, String value) {
  final asKey = context.tr(value);
  return asKey == value ? localizedErrorMessage(context, value) : asKey;
}

/// Shows [message] as a snack bar, translated for the active locale.
extension ErrorSnackBarContext on BuildContext {
  void showErrorSnackBar(String? message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(localizedErrorMessage(this, message))),
    );
  }
}
