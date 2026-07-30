import 'package:freezed_annotation/freezed_annotation.dart';
import 'role.dart';
import 'tenant_ref.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Wire shape for the `User` object returned by `GET /users/me`,
/// `POST /auth/login`, and `POST /auth/refresh` per API_CONTRACT.md §1-2.
///
/// Rebuilt 2026-07-30 for a backend update: `firstName`/`lastName`/`isActive`/
/// `phone` no longer exist (this is the second shape this entity has had in
/// one day — first a UI-mockup shape, then this rebuild). `fullName` and
/// `status` are now real API fields, not derived client-side.
@freezed
abstract class User with _$User {
  const User._();

  const factory User({
    required String id,
    required String email,
    required String fullName,
    required bool isSuperAdmin,
    required String status,
    required bool mfaEnabled,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? avatarUrl,
    DateTime? lastLoginAt,
    required List<Role> roles,
    required TenantRef tenant,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Flattens permission codes across all of this user's roles. Generic by
  /// design — no enumerated `code` values are shown anywhere in
  /// API_CONTRACT.md, so this can't be narrowed to a typed set without a
  /// live example response.
  bool hasPerm(String permissionCode) {
    return roles.any(
      (role) => role.permissions.any(
        (permission) => permission.code == permissionCode,
      ),
    );
  }

  /// BR-005: Firm Admin must always have full, non-restrictable CRUD.
  /// `role.code` (e.g. plausibly "FIRM_ADMIN") is a much more promising
  /// signal than the previous shape's `role.name`/display-name fields were,
  /// but no example anywhere in API_CONTRACT.md shows a real value — still
  /// not guessing it. Confirm the actual value against a live login
  /// response before wiring this into any UI gating.
  bool get isFirmAdmin => false;
}
