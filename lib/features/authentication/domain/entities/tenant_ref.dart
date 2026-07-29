import 'package:freezed_annotation/freezed_annotation.dart';

part 'tenant_ref.freezed.dart';
part 'tenant_ref.g.dart';

/// Wire shape for the nested `tenant` object on `GET /users/me` per
/// API_CONTRACT.md §2. Only `id`/`name` are shown in the collection's
/// examples — richer firm data comes from `GET /tenants/my-firm` (not part
/// of M1).
@freezed
abstract class TenantRef with _$TenantRef {
  const factory TenantRef({required String id, required String name}) =
      _TenantRef;

  factory TenantRef.fromJson(Map<String, dynamic> json) =>
      _$TenantRefFromJson(json);
}
