import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/network/api_config.dart';
import 'package:hqooq/core/utils/cache_busted_url.dart';

void main() {
  group('resolveImageUrl', () {
    test('keeps an absolute remote URL unchanged', () {
      const url = 'https://cdn.example.com/avatars/user.png';

      expect(resolveImageUrl(url), url);
    });

    test('resolves a relative image URL against the API host', () {
      expect(
        resolveImageUrl('/uploads/avatars/user.png'),
        '${ApiConfig.host}/uploads/avatars/user.png',
      );
    });

    test('replaces localhost with the configured API host', () {
      final configuredHost = Uri.parse(ApiConfig.host);
      final resolved = Uri.parse(
        resolveImageUrl('http://localhost:3006/uploads/user.png')!,
      );

      expect(resolved.scheme, configuredHost.scheme);
      expect(resolved.host, configuredHost.host);
      expect(resolved.port, configuredHost.port);
      expect(resolved.path, '/uploads/user.png');
    });

    test('returns null for a blank URL', () {
      expect(resolveImageUrl('  '), isNull);
    });
  });

  test('cacheBustedUrl resolves the URL and appends an encoded version', () {
    expect(
      cacheBustedUrl('/uploads/user.png?size=small', '2026-09-25 10:00'),
      '${ApiConfig.host}/uploads/user.png?size=small&v=2026-09-25%2010%3A00',
    );
  });
}
