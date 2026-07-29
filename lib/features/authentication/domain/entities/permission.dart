import 'package:freezed_annotation/freezed_annotation.dart';

part 'permission.freezed.dart';
part 'permission.g.dart';

/// Wire shape for `roles[].permissions[]` per API_CONTRACT.md §2 (`GET /users/me`).
/// No enumerated `resource`/`action` values are shown anywhere in the Postman
/// collection's examples — treat them as opaque strings until seen live.
@freezed
abstract class Permission with _$Permission {
  const factory Permission({
    required String id,
    required String resource,
    required String action,
    required String displayNameEn,
    required String displayNameAr,
  }) = _Permission;

  factory Permission.fromJson(Map<String, dynamic> json) =>
      _$PermissionFromJson(json);
}
