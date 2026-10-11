import 'package:freezed_annotation/freezed_annotation.dart';

part 'case_type_lookup.freezed.dart';
part 'case_type_lookup.g.dart';

/// Wire shape for the nested `caseType` object on `GET/POST/PATCH /cases`
/// per API_CONTRACT.md §8 — confirms lookups exist as real entities
/// server-side, though no standalone `GET /lookups`-style endpoint is
/// exposed in this collection to fetch them independently.
@freezed
abstract class CaseTypeLookup with _$CaseTypeLookup {
  const CaseTypeLookup._();
  const factory CaseTypeLookup({
    required String id,
    required String name,
    @Default('') String labelEn,
    @Default('') String labelAr,
  }) = _CaseTypeLookup;

  String labelFor(String languageCode) {
    if (languageCode == 'ar' && labelAr.isNotEmpty) return labelAr;
    if (labelEn.isNotEmpty) return labelEn;
    return name;
  }

  factory CaseTypeLookup.fromJson(Map<String, dynamic> json) =>
      _$CaseTypeLookupFromJson({
        ...json,
        'name': json['name'] ?? json['labelEn'] ?? json['code'] ?? '',
        'labelEn': json['labelEn'] ?? json['name'] ?? json['code'] ?? '',
        'labelAr': json['labelAr'] ?? '',
      });
}
