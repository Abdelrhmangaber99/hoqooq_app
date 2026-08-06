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
///
/// **`tenant` is genuinely nullable — confirmed live 2026-08-06, not a
/// relations-loading question.** A `SUPER_ADMIN` platform account (no
/// `tenantId` at all, `isSuperAdmin: true`) returns `tenant: null` — this
/// app's real intended actors are always tenant-scoped firm staff (BR-037),
/// but a tenant-less account must still parse without crashing, e.g. for
/// diagnostics/session-restore. See the two `sessionState.user.tenant?.id`
/// call sites (`ClientRepository`/`CaseRepository`'s create flows) for the
/// only places this null needs handling — both already degrade to omitting
/// `tenantId` from the request rather than crashing.
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
    TenantRef? tenant,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Flattens permission codes across all of this user's roles. Confirmed
  /// format from the actual backend source
  /// (`src/core/constants/permissions.constant.ts`): `<module>.<action>`,
  /// e.g. `cases.read`.
  bool hasPerm(String permissionCode) {
    return roles.any(
      (role) => role.permissions.any(
        (permission) => permission.code == permissionCode,
      ),
    );
  }

  /// BR-005: true iff this user holds the `FIRM_ADMIN` role — confirmed
  /// by the backend team as the real mechanism (2026-08-05), and
  /// independently confirmed by reading every server-side "is this user a
  /// firm admin" check in the backend source, all of which check
  /// `roles.includes('FIRM_ADMIN')`. Supersedes the earlier
  /// `Tenant.ownerUserId == user.id` mechanism (API_CONTRACT.md finding
  /// D), which is no longer what the backend itself uses and should not
  /// be relied on going forward — see finding L.
  bool get isFirmAdmin => roles.any((role) => role.code == 'FIRM_ADMIN');
}
