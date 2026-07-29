import 'package:freezed_annotation/freezed_annotation.dart';
import 'permission.dart';

part 'role.freezed.dart';
part 'role.g.dart';

/// Wire shape for `roles[]` per API_CONTRACT.md §2 (`GET /users/me`).
/// No example in the collection shows a real `name` value (e.g. whether the
/// Firm Admin role is named "FIRM_ADMIN", "firm_admin", or something else) —
/// isFirmAdmin-style detection is deliberately not implemented against this
/// field yet. See CLAUDE.md open items.
@freezed
abstract class Role with _$Role {
  const factory Role({
    required String id,
    required String name,
    required String displayNameEn,
    required String displayNameAr,
    required List<Permission> permissions,
  }) = _Role;

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
}
