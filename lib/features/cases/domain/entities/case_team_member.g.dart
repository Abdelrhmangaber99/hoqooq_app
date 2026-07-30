// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_team_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CaseTeamMember _$CaseTeamMemberFromJson(Map<String, dynamic> json) =>
    _CaseTeamMember(
      id: json['id'] as String,
      roleOnCase: json['roleOnCase'] as String,
      userId: json['userId'] as String,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CaseTeamMemberToJson(_CaseTeamMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'roleOnCase': instance.roleOnCase,
      'userId': instance.userId,
      'user': instance.user,
    };
