import 'package:freezed_annotation/freezed_annotation.dart';

part 'permission.freezed.dart';
part 'permission.g.dart';

/// Wire shape for `roles[].permissions[]` per API_CONTRACT.md §2 (`GET
/// /users/me`).
///
/// Rebuilt 2026-07-30 for a backend update: `resource`/`action`/
/// `displayNameEn`/`displayNameAr` no longer exist, replaced by a single
/// opaque `code` string. No enumerated values are shown anywhere in
/// API_CONTRACT.md.
@freezed
abstract class Permission with _$Permission {
  const factory Permission({required String id, required String code}) =
      _Permission;

  factory Permission.fromJson(Map<String, dynamic> json) =>
      _$PermissionFromJson(json);
}
