import 'package:freezed_annotation/freezed_annotation.dart';
import 'permission.dart';

part 'role.freezed.dart';
part 'role.g.dart';

/// Wire shape for `roles[]` per API_CONTRACT.md §2 (`GET /users/me`).
///
/// Rebuilt 2026-07-30 for a backend update: `name`/`displayNameEn`/
/// `displayNameAr` no longer exist, replaced by `code`/`scope`. No example
/// shows a real `code` value (e.g. whether the Firm Admin role is
/// "FIRM_ADMIN") — isFirmAdmin-style detection still isn't implemented
/// against this field. See CLAUDE.md open items.
@freezed
abstract class Role with _$Role {
  const factory Role({
    required String id,
    required String code,
    required String scope,
    required List<Permission> permissions,
  }) = _Role;

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
}
