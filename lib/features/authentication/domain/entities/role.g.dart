// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Role _$RoleFromJson(Map<String, dynamic> json) => _Role(
  id: json['id'] as String,
  code: json['code'] as String,
  scope: json['scope'] as String,
  permissions: (json['permissions'] as List<dynamic>)
      .map((e) => Permission.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RoleToJson(_Role instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'scope': instance.scope,
  'permissions': instance.permissions,
};
