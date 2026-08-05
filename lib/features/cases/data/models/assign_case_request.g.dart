// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assign_case_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AssignCaseRequest _$AssignCaseRequestFromJson(Map<String, dynamic> json) =>
    _AssignCaseRequest(
      userId: json['userId'] as String,
      accessLevel: $enumDecode(_$CaseAccessLevelEnumMap, json['accessLevel']),
    );

Map<String, dynamic> _$AssignCaseRequestToJson(_AssignCaseRequest instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'accessLevel': _$CaseAccessLevelEnumMap[instance.accessLevel]!,
    };

const _$CaseAccessLevelEnumMap = {
  CaseAccessLevel.fullAccess: 'FULL_ACCESS',
  CaseAccessLevel.readOnly: 'READ_ONLY',
  CaseAccessLevel.uploadDocuments: 'UPLOAD_DOCUMENTS',
  CaseAccessLevel.assignHearing: 'ASSIGN_HEARING',
  CaseAccessLevel.unknown: 'unknown',
};
