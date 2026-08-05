// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lookup.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Lookup _$LookupFromJson(Map<String, dynamic> json) => _Lookup(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  kind: $enumDecode(
    _$LookupKindEnumMap,
    json['kind'],
    unknownValue: LookupKind.unknown,
  ),
  labelEn: json['labelEn'] as String,
  labelAr: json['labelAr'] as String,
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$LookupToJson(_Lookup instance) => <String, dynamic>{
  'id': instance.id,
  'tenantId': instance.tenantId,
  'kind': _$LookupKindEnumMap[instance.kind]!,
  'labelEn': instance.labelEn,
  'labelAr': instance.labelAr,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$LookupKindEnumMap = {
  LookupKind.caseType: 'CASE_TYPE',
  LookupKind.hearingType: 'HEARING_TYPE',
  LookupKind.documentCategory: 'DOCUMENT_CATEGORY',
  LookupKind.expenseCategory: 'EXPENSE_CATEGORY',
  LookupKind.unknown: 'unknown',
};
