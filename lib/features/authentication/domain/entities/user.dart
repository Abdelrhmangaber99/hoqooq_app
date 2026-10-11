import 'package:freezed_annotation/freezed_annotation.dart';
import 'tenant_ref.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Wire shape for the `User` object returned by `GET /users/me`, matching the
/// live backend's OpenAPI schema directly (`GET /api/docs-json` on the dev API
/// identifies itself as "HOQOOQ API 3.0.0"; `UserResponseDto` requires
/// `id`, `email`, `fullName`, `status`, `accountType`, `createdAt`,
/// `updatedAt` and offers `avatarUrl`, `jobClassification`, `phone`,
/// `lastLoginAt`, `tenant`, `permissions`).
///
/// **Rebuilt 2026-10-11 for the v3 identity contract: `isSuperAdmin` and
/// `mfaEnabled` are gone from this response entirely** — v2's migration plan
/// explicitly removes client-visible platform/security fields from the user
/// payload. Both used to be `required bool` fields here, so decoding a
/// response that no longer carries either key threw
/// `type 'Null' is not a subtype of type 'bool'` inside the generated
/// `_$UserFromJson`, which escaped `AuthRepository.getCurrentUser()` (it only
/// catches `DioException`), killed the `AuthBloc` event handler mid-flight,
/// and left the app stuck in `AuthLoading` — a sign-in button that spins
/// forever, or a splash screen that never advances.
///
/// [isSuperAdmin] is now a getter derived from `accountType`, exactly like
/// [isFirmAdmin] already was, so platform routing keeps working without a
/// field the wire no longer sends. [mfaEnabled] was unused by the UI and is
/// simply dropped.
///
/// **`tenant` is genuinely nullable, not a relations-loading question.** A
/// platform account (no `tenantId` at all) returns `tenant: null` — see the
/// two `sessionState.user.tenant?.id` call sites in `ClientRepository` /
/// `CaseRepository`'s create flows, the only places this null needs handling;
/// both degrade to omitting `tenantId` from the request rather than crashing.
@freezed
abstract class User with _$User {
  const User._();

  const factory User({
    required String id,
    required String email,
    required String fullName,
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? avatarUrl,
    DateTime? lastLoginAt,
    String? accountType,
    String? jobClassification,
    String? phone,
    @Default(<String>[]) List<String> permissions,
    TenantRef? tenant,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  bool hasPerm(String permissionCode) => permissions.contains(permissionCode);

  /// BR-002/BR-005: exactly three account types (`SUPER_ADMIN`/
  /// `FIRM_ADMIN`/`EMPLOYEE`), and both privilege checks are derived from
  /// `accountType` alone — the v2 PRD's replacement of the old role-code
  /// mechanism. Both default to `false` when `accountType` is absent, the
  /// same secure-default direction as `agreedFee` gating (BR-026).
  bool get isSuperAdmin => accountType == 'SUPER_ADMIN';
  bool get isFirmAdmin => accountType == 'FIRM_ADMIN';
  bool get isEmployee => accountType == 'EMPLOYEE';
  bool get isLawyer => jobClassification == 'LAWYER';
  bool get isActive => status == 'ACTIVE';

  bool hasAnyPermission(Iterable<String> permissionCodes) =>
      permissionCodes.any(hasPerm);
}
