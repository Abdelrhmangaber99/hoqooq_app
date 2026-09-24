import 'package:freezed_annotation/freezed_annotation.dart';
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
    String? accountType,
    String? jobClassification,
    @Default(<String>[]) List<String> permissions,
    TenantRef? tenant,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  bool hasPerm(String permissionCode) => permissions.contains(permissionCode);

  /// BR-002/BR-005: exactly three account types (`SUPER_ADMIN`/
  /// `FIRM_ADMIN`/`EMPLOYEE`); Firm Admin is determined solely by
  /// `accountType`, per the v2 PRD's replacement of the old
  /// role-code-based mechanism.
  bool get isFirmAdmin => accountType == 'FIRM_ADMIN';
  bool get isEmployee => accountType == 'EMPLOYEE';
  bool get isLawyer => jobClassification == 'LAWYER';
  bool get isActive => status == 'ACTIVE';

  bool hasAnyPermission(Iterable<String> permissionCodes) =>
      permissionCodes.any(hasPerm);
}
