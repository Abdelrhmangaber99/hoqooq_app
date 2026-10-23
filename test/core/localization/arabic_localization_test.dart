import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/auth/permission_labels.dart';

void main() {
  late Map<String, dynamic> english;
  late Map<String, dynamic> arabic;

  setUpAll(() {
    english =
        jsonDecode(File('assets/lang/en.json').readAsStringSync())
            as Map<String, dynamic>;
    arabic =
        jsonDecode(File('assets/lang/ar.json').readAsStringSync())
            as Map<String, dynamic>;
  });

  test('every English localization key has an Arabic translation', () {
    expect(arabic.keys, containsAll(english.keys));
  });

  test('every backend permission has a proper Arabic label', () {
    for (final code in knownPermissionCodes) {
      final key = permissionTranslationKey(code);
      expect(arabic, contains(key), reason: 'Missing Arabic label for $code');
      expect(english, contains(key), reason: 'Missing English label for $code');

      final value = arabic[key] as String;
      expect(
        value,
        matches(RegExp(r'[\u0600-\u06FF]')),
        reason: '$code is not translated into Arabic',
      );
      expect(
        value,
        isNot(english[key]),
        reason: '$code still uses its English label in Arabic',
      );
    }
  });

  test('legacy permission codes resolve to translated current labels', () {
    for (final entry in legacyPermissionAliases.entries) {
      final canonical = canonicalPermissionCode(entry.key.toUpperCase());
      expect(canonical, entry.value);
      expect(knownPermissionCodes, contains(canonical));
      expect(arabic, contains(permissionTranslationKey(canonical)));
    }
  });

  test('Arabic UI strings do not contain unapproved English text', () {
    // Brand names and file extensions are intentionally not translated.
    const technicalTextKeys = {
      'no_backend_courts_for_hearing',
      'osm_attribution',
      'upload_file_type_unsupported',
    };

    final unexpected = <String>[];
    for (final entry in arabic.entries) {
      if (technicalTextKeys.contains(entry.key)) continue;
      // `{cases}`/`{tasks}`-style placeholders are substituted at runtime and
      // are never shown to the user, so they are not English UI copy — only
      // the surrounding text is checked.
      final visibleText = (entry.value as String).replaceAll(
        RegExp(r'\{[a-zA-Z0-9_]+\}'),
        '',
      );
      if (visibleText.contains(RegExp(r'[A-Za-z]'))) {
        unexpected.add(entry.key);
      }
    }

    expect(
      unexpected,
      isEmpty,
      reason: 'Arabic mode contains English text in: $unexpected',
    );
  });
}
