import 'package:freezed_annotation/freezed_annotation.dart';
import 'role.dart';
import 'tenant_ref.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Wire shape for the `User` object returned by `GET /users/me`,
/// `POST /auth/login`, and `POST /auth/refresh` per API_CONTRACT.md §1-2.
/// Deliberately matches the collection's camelCase field names exactly —
/// this replaces the earlier prototype shape (fullName/role enum/lawFirmName)
/// which had no basis in the real API.
@freezed
abstract class User with _$User {
  const User._();

  const factory User({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? phone,
    String? avatarUrl,
    DateTime? lastLoginAt,
    required List<Role> roles,
    required TenantRef tenant,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  String get fullName => '$firstName $lastName';

  /// Flattens permissions across all of this user's roles. Generic by
  /// design — no `resource`/`action` values are enumerated anywhere in
  /// API_CONTRACT.md, so this can't be narrowed further without a live
  /// example response.
  bool hasPerm(String resource, String action) {
    return roles.any(
      (role) => role.permissions.any(
        (permission) =>
            permission.resource == resource && permission.action == action,
      ),
    );
  }

  /// BR-005: Firm Admin must always have full, non-restrictable CRUD.
  /// No example anywhere in API_CONTRACT.md shows a real `role.name` value
  /// (e.g. whether it's "FIRM_ADMIN"), so this can't be detected reliably
  /// yet. Scaffolded per PLAN.md §5 — confirm the real value against a live
  /// login response before wiring this into any UI gating.
  bool get isFirmAdmin => false;
}
