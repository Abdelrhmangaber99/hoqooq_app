// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_team_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CaseTeamMember _$CaseTeamMemberFromJson(Map<String, dynamic> json) =>
    _CaseTeamMember(
      id: json['id'] as String,
      accessLevel: $enumDecode(
        _$CaseAccessLevelEnumMap,
        json['accessLevel'],
        unknownValue: CaseAccessLevel.unknown,
      ),
      userId: json['userId'] as String,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CaseTeamMemberToJson(_CaseTeamMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accessLevel': _$CaseAccessLevelEnumMap[instance.accessLevel]!,
      'userId': instance.userId,
      'user': instance.user,
    };

const _$CaseAccessLevelEnumMap = {
  CaseAccessLevel.fullAccess: 'FULL_ACCESS',
  CaseAccessLevel.readOnly: 'READ_ONLY',
  CaseAccessLevel.uploadDocuments: 'UPLOAD_DOCUMENTS',
  CaseAccessLevel.assignHearing: 'ASSIGN_HEARING',
  CaseAccessLevel.unknown: 'unknown',
};
