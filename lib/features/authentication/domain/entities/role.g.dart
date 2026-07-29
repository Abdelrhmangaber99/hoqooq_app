// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Role _$RoleFromJson(Map<String, dynamic> json) => _Role(
  id: json['id'] as String,
  name: json['name'] as String,
  displayNameEn: json['displayNameEn'] as String,
  displayNameAr: json['displayNameAr'] as String,
  permissions: (json['permissions'] as List<dynamic>)
      .map((e) => Permission.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RoleToJson(_Role instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'displayNameEn': instance.displayNameEn,
  'displayNameAr': instance.displayNameAr,
  'permissions': instance.permissions,
};
