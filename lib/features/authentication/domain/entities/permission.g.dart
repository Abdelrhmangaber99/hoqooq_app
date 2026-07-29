// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Permission _$PermissionFromJson(Map<String, dynamic> json) => _Permission(
  id: json['id'] as String,
  resource: json['resource'] as String,
  action: json['action'] as String,
  displayNameEn: json['displayNameEn'] as String,
  displayNameAr: json['displayNameAr'] as String,
);

Map<String, dynamic> _$PermissionToJson(_Permission instance) =>
    <String, dynamic>{
      'id': instance.id,
      'resource': instance.resource,
      'action': instance.action,
      'displayNameEn': instance.displayNameEn,
      'displayNameAr': instance.displayNameAr,
    };
