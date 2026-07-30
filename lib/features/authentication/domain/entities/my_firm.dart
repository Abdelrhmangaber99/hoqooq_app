import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_firm.freezed.dart';
part 'my_firm.g.dart';

/// Wire shape for `GET /tenants/my-firm`. Confirmed from the actual
/// backend source (`tenants.controller.ts` returns the raw `Tenant`
/// entity, not a filtered DTO, unlike most other endpoints) — this model
/// only picks out the three fields the app actually needs; any other
/// fields on the raw entity (address, currency, timezone, subscription,
/// audit columns, etc.) are ignored by `fromJson`, not modeled here since
/// nothing uses them yet.
///
/// `ownerUserId` is the mechanism for detecting Firm Admin (BR-005): a
/// user is the Firm Admin of their tenant iff `ownerUserId == user.id`.
/// There is no dedicated "firm_admin" role — confirmed from the backend's
/// seed data (`src/infrastructure/database/seeds/seed.ts`), which only
/// seeds `admin` (Super Admin, SYSTEM scope), `lawyer`, `secretary`,
/// `assistant`, `accountant`, `client` (all TENANT scope).
@freezed
abstract class MyFirm with _$MyFirm {
  const factory MyFirm({
    required String id,
    required String name,
    required String ownerUserId,
  }) = _MyFirm;

  factory MyFirm.fromJson(Map<String, dynamic> json) => _$MyFirmFromJson(json);
}
