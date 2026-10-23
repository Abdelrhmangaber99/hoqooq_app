import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/cache_busted_url.dart';

/// The one place an account photo is rendered, so every surface (app bar,
/// profile, settings, employee list, firm cards) falls back identically.
///
/// **Backend reality (verified against the deployed API's OpenAPI document and
/// a captured live `GET /users/me`, 2026-10-15):** there is exactly one avatar
/// field — `avatarUrl` on the user payload, a nullable URL string that
/// `PATCH /users/me` (`UpdateProfileDto {fullName, avatarUrl, phone}`) accepts.
/// The backend exposes **no** avatar/profile-picture upload route; its only
/// image-upload endpoints are firm logos (`POST /tenants/my-firm/logo`,
/// `POST /tenants/:id/logo`). So a user photo must already live at a URL —
/// this widget never guesses alternate field names (`avatar`, `photoUrl`,
/// `profileImage`, …) and never falls back to a locally picked file, because
/// none of those exist on the wire.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 40,
    this.borderRadius,
    this.version,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// Used only for the initials fallback, and for the semantics label.
  final String name;

  /// The backend's `avatarUrl`. Null/blank renders the initials fallback.
  final String? imageUrl;

  final double size;

  /// Null renders a circle; a value renders a rounded square.
  final BorderRadius? borderRadius;

  /// Cache-busting token (typically the user's `updatedAt`): Flutter's image
  /// cache is keyed by URL, so a photo re-saved at the same URL would
  /// otherwise keep showing the stale bitmap.
  final Object? version;

  final Color? backgroundColor;
  final Color? foregroundColor;

  /// Up to two initials, so "Jane Doe" reads as "JD" and "youssef" as "Y".
  static String initialsOf(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.characters.first.toUpperCase());
    final joined = parts.join();
    return joined.isEmpty ? '?' : joined;
  }

  @override
  Widget build(BuildContext context) {
    final raw = imageUrl?.trim();
    final resolved = (raw == null || raw.isEmpty)
        ? null
        : (version == null ? resolveImageUrl(raw) : cacheBustedUrl(raw, version));

    // Initials fallback colours mirror the reference web/desktop app's avatar
    // (`bg-ink-800 text-white` — verified in the shipped bundle), not the
    // brass pair this used to default to. It is the one chip that appears in
    // both the desktop sidebar and the mobile top bar, so a different colour
    // here is immediately visible side by side.
    final foreground = foregroundColor ?? Colors.white;
    final fallback = Center(
      child: Text(
        initialsOf(name),
        style: AppTypography.labelLarge.copyWith(
          color: foreground,
          fontSize: (size * 0.36).clamp(10.0, 22.0),
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Semantics(
      label: name,
      image: resolved != null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.ink800,
          shape: borderRadius == null ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: borderRadius,
        ),
        clipBehavior: Clip.antiAlias,
        child: resolved == null
            ? fallback
            : Image.network(
                resolved,
                // A photo that fails to load (expired URL, offline) must
                // degrade to initials, never to a broken-image box.
                errorBuilder: (_, _, _) => fallback,
                fit: BoxFit.cover,
                width: size,
                height: size,
              ),
      ),
    );
  }
}
