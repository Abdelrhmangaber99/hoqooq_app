import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import 'package:hqooq/core/localization/error_messages.dart';

/// Serves an already-built [AppLocalizations] synchronously, so the test never
/// waits on `rootBundle` (see `login_page_test.dart` for the same pattern).
class _SyncDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _SyncDelegate(this._localizations);

  final AppLocalizations _localizations;

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(_localizations);

  @override
  bool shouldReload(_SyncDelegate old) => false;
}

void main() {
  late Map<String, String> arabicStrings;
  late AppLocalizations arabic;

  setUpAll(() {
    final raw =
        jsonDecode(File('assets/lang/ar.json').readAsStringSync())
            as Map<String, dynamic>;
    arabicStrings = raw.map((key, value) => MapEntry(key, value.toString()));
    arabic = AppLocalizations.withMap(const Locale('ar'), arabicStrings);
  });

  /// Runs [localizedErrorMessage] for [message] inside an Arabic locale and
  /// returns the displayed text.
  Future<String> translate(WidgetTester tester, String? message) async {
    late String result;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: [
          _SyncDelegate(arabic),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ar')],
        home: Builder(
          builder: (context) {
            result = localizedErrorMessage(context, message);
            return const SizedBox();
          },
        ),
      ),
    );
    return result;
  }

  testWidgets('maps the login/identity sentences into Arabic', (tester) async {
    // These are the sentences a signed-out user sees first, so an unmapped one
    // is the difference between the app looking translated and half-English.
    const cases = <String, String>{
      'Invalid credentials': 'error_invalid_credentials',
      'Invalid credentials or MFA code': 'error_invalid_credentials_or_mfa',
      'Invalid MFA code': 'error_invalid_mfa_code',
      'MFA setup and verification are required': 'error_mfa_required',
      'Account is inactive': 'error_account_inactive',
      'Firm is inactive': 'error_firm_inactive',
      'Incorrect old password': 'error_incorrect_old_password',
      'Invalid or expired activation token': 'error_invalid_activation_link',
      'Invalid or expired reset token': 'error_invalid_reset_link',
      'Invitation was already used': 'error_invitation_already_used',
      'Platform permission required': 'error_platform_permission_required',
    };

    for (final entry in cases.entries) {
      final actual = await translate(tester, entry.key);
      expect(actual, arabicStrings[entry.value], reason: entry.key);
      expect(
        actual,
        matches(RegExp(r'[\u0600-\u06FF]')),
        reason: '${entry.key} must translate into Arabic',
      );
    }
  });

  testWidgets('class-validator defaults translate instead of leaking English', (
    tester,
  ) async {
    final mapped = <String, String>{
      'email must be an email': arabicStrings['invalid_email']!,
      'password should not be empty': arabicStrings['field_required']!,
      'password must be longer than or equal to 6 characters':
          arabicStrings['error_value_too_short']!,
      'property status should not exist':
          arabicStrings['error_unexpected_field']!,
    };
    for (final entry in mapped.entries) {
      expect(
        await translate(tester, entry.key),
        entry.value,
        reason: entry.key,
      );
    }
  });

  testWidgets('unknown text passes through untouched', (tester) async {
    expect(
      await translate(tester, 'Some sentence only the backend knows'),
      'Some sentence only the backend knows',
    );
  });

  testWidgets('an empty message becomes the generic error', (tester) async {
    expect(await translate(tester, null), arabicStrings['error_generic']);
    expect(await translate(tester, '   '), arabicStrings['error_generic']);
  });
}
