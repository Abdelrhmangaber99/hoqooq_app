// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assign_case_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AssignCaseRequest _$AssignCaseRequestFromJson(Map<String, dynamic> json) =>
    _AssignCaseRequest(
      userId: json['userId'] as String,
      capabilities: (json['capabilities'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$AssignCaseRequestToJson(_AssignCaseRequest instance) =>
    <String, dynamic>{'capabilities': instance.capabilities};
