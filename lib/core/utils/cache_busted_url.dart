import '../network/api_config.dart';

/// Resolves relative URLs or localhost URLs to a fully qualified absolute URL
/// using [ApiConfig.host].
String? resolveImageUrl(String? url) {
  if (url == null || url.trim().isEmpty) return null;
  final trimmed = url.trim();

  // Handle localhost / 127.0.0.1 replacement for physical device / emulator testing
  if (trimmed.startsWith('http://localhost:') ||
      trimmed.startsWith('https://localhost:') ||
      trimmed.startsWith('http://127.0.0.1:') ||
      trimmed.startsWith('https://127.0.0.1:')) {
    try {
      final uri = Uri.parse(trimmed);
      final hostUri = Uri.parse(ApiConfig.host);
      final resolvedUri = uri.replace(
        scheme: hostUri.scheme,
        host: hostUri.host,
        port: hostUri.port,
      );
      return resolvedUri.toString();
    } catch (_) {
      return trimmed;
    }
  }

  // Handle absolute HTTP/HTTPS URLs
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }

  // Handle relative URLs (e.g. /uploads/avatar.png or uploads/avatar.png)
  final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
  return '${ApiConfig.host}$path';
}

/// Appends a cache-busting query parameter derived from [version] after
/// resolving relative/localhost URLs into absolute network URLs.
String cacheBustedUrl(String url, Object? version) {
  final resolved = resolveImageUrl(url) ?? url;
  if (version == null) return resolved;
  final separator = resolved.contains('?') ? '&' : '?';
  return '$resolved${separator}v=${Uri.encodeComponent(version.toString())}';
}
