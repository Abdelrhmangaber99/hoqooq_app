// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  email: json['email'] as String,
  fullName: json['fullName'] as String,
  isSuperAdmin: json['isSuperAdmin'] as bool,
  status: json['status'] as String,
  mfaEnabled: json['mfaEnabled'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  avatarUrl: json['avatarUrl'] as String?,
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
  accountType: json['accountType'] as String?,
  jobClassification: json['jobClassification'] as String?,
  permissions:
      (json['permissions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  tenant: json['tenant'] == null
      ? null
      : TenantRef.fromJson(json['tenant'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'fullName': instance.fullName,
  'isSuperAdmin': instance.isSuperAdmin,
  'status': instance.status,
  'mfaEnabled': instance.mfaEnabled,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'avatarUrl': instance.avatarUrl,
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
  'accountType': instance.accountType,
  'jobClassification': instance.jobClassification,
  'permissions': instance.permissions,
  'tenant': instance.tenant,
};
