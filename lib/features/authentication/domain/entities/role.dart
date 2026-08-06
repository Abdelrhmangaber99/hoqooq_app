import 'package:freezed_annotation/freezed_annotation.dart';
import 'permission.dart';

part 'role.freezed.dart';
part 'role.g.dart';

/// Wire shape for `roles[]` per API_CONTRACT.md §2 (`GET /users/me`).
///
/// Rebuilt 2026-07-30 for a backend update: `name`/`displayNameEn`/
/// `displayNameAr` no longer exist, replaced by `code`/`scope`.
///
/// **`permissions` is not reliably present — confirmed 2026-08-06 against
/// a live response, root-caused in the backend source, not guessed.**
/// `UsersController` builds `roles` via `@Transform(({obj}) =>
/// obj.userRoles.map(ur => ur.role)) @Type(() => RoleResponseDto)` — but
/// `class-transformer` does not re-run `RoleResponseDto`'s own
/// `@Expose`/`@Transform` rules on a value a sibling `@Transform` already
/// produced (a known `class-transformer` interaction, not a Flutter-side
/// assumption). The real, observed `GET /users/me` response nests the
/// **raw** `Role` entity per role instead: no `permissions` key at all,
/// but the raw `rolePermissions: [{permission: {id, code}}]` join array
/// is present verbatim. `GET /roles` (list endpoint, no `plainToInstance`
/// involved at all) returns yet a third shape — `{id, code, scope}` only,
/// neither key present.
///
/// `fromJson` below handles all three shapes: prefers a clean
/// `permissions` list if the backend ever sends one, falls back to
/// deriving codes from `rolePermissions[].permission` when `permissions`
/// is absent, and only defaults to `[]` when neither key exists at all.
/// Deliberately not a plain `@JsonKey(defaultValue: [])` — defaulting to
/// `[]` outright would silently return `false` from every `User.hasPerm()`
/// check, hiding every RBAC-gated action in the app instead of just
/// avoiding a crash.
@freezed
abstract class Role with _$Role {
  const factory Role({
    required String id,
    required String code,
    required String scope,
    required List<Permission> permissions,
  }) = _Role;

  factory Role.fromJson(Map<String, dynamic> json) =>
      _$RoleFromJson(_normalizeRoleJson(json));
}

/// Backfills `permissions` from the raw `rolePermissions` join array when
/// the clean field is absent, before handing off to the generated
/// `_$RoleFromJson` — see `Role`'s doc comment for why.
Map<String, dynamic> _normalizeRoleJson(Map<String, dynamic> json) {
  if (json['permissions'] != null) return json;
  final rawRolePermissions = json['rolePermissions'];
  return {
    ...json,
    'permissions': rawRolePermissions is List
        ? rawRolePermissions
              .map((rp) => (rp as Map<String, dynamic>)['permission'])
              .toList()
        : const <dynamic>[],
  };
}
