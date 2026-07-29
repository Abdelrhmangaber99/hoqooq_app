import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Persists only the refresh token, per BR-033 / spec §12: refresh token in
/// secure storage (Keychain / EncryptedSharedPreferences), access token in
/// memory only — never written here, never to Hive/SharedPreferences.
@lazySingleton
class TokenStorage {
  const TokenStorage();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const _refreshTokenKey = 'refresh_token';

  Future<void> saveRefreshToken(String refreshToken) =>
      _storage.write(key: _refreshTokenKey, value: refreshToken);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> clear() => _storage.delete(key: _refreshTokenKey);
}
