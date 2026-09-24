import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'lookup_kind.dart';

part 'lookup.freezed.dart';
part 'lookup.g.dart';

/// Wire shape for `GET /lookups?kind=...` per API_CONTRACT.md finding K.
///
/// `LookupsController` doesn't apply `plainToInstance` — this is the raw
/// `Lookup` entity (`src/modules/settings/entities/lookup.entity.ts`),
/// tenant-scoped. `labelEn`/`labelAr` are tenant-authored data (a firm's
/// own case-type/hearing-type names), not app strings — resolved via
/// [labelFor], never through the JSON `context.tr()` localization system.
@freezed
abstract class Lookup with _$Lookup {
  const Lookup._();

  const factory Lookup({
    required String id,
    String? tenantId,
    @JsonKey(unknownEnumValue: LookupKind.unknown) required LookupKind kind,
    required String labelEn,
    required String labelAr,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Lookup;

  factory Lookup.fromJson(Map<String, dynamic> json) => _$LookupFromJson(json);

  String labelFor(Locale locale) =>
      locale.languageCode == 'ar' ? labelAr : labelEn;
}
