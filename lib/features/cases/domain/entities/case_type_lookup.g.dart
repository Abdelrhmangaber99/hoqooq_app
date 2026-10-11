// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_type_lookup.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CaseTypeLookup _$CaseTypeLookupFromJson(Map<String, dynamic> json) =>
    _CaseTypeLookup(
      id: json['id'] as String,
      name: json['name'] as String,
      labelEn: json['labelEn'] as String? ?? '',
      labelAr: json['labelAr'] as String? ?? '',
    );

Map<String, dynamic> _$CaseTypeLookupToJson(_CaseTypeLookup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'labelEn': instance.labelEn,
      'labelAr': instance.labelAr,
    };
