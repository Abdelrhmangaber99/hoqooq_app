// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_password_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChangePasswordRequest _$ChangePasswordRequestFromJson(
  Map<String, dynamic> json,
) => _ChangePasswordRequest(
  oldPassword: json['oldPassword'] as String,
  newPassword: json['newPassword'] as String,
);

Map<String, dynamic> _$ChangePasswordRequestToJson(
  _ChangePasswordRequest instance,
) => <String, dynamic>{
  'oldPassword': instance.oldPassword,
  'newPassword': instance.newPassword,
};
