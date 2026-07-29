// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  email: json['email'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  phone: json['phone'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
  roles: (json['roles'] as List<dynamic>)
      .map((e) => Role.fromJson(e as Map<String, dynamic>))
      .toList(),
  tenant: TenantRef.fromJson(json['tenant'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'phone': instance.phone,
  'avatarUrl': instance.avatarUrl,
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
  'roles': instance.roles,
  'tenant': instance.tenant,
};
