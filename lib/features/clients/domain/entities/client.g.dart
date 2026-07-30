// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Client _$ClientFromJson(Map<String, dynamic> json) => _Client(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  clientCode: json['clientCode'] as String,
  type: $enumDecode(
    _$ClientTypeEnumMap,
    json['type'],
    unknownValue: ClientType.unknown,
  ),
  fullName: json['fullName'] as String,
  status: $enumDecode(
    _$ClientStatusEnumMap,
    json['status'],
    unknownValue: ClientStatus.unknown,
  ),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  nationalId: json['nationalId'] as String?,
  commercialReg: json['commercialReg'] as String?,
  emails: (json['emails'] as List<dynamic>).map((e) => e as String).toList(),
  phones: (json['phones'] as List<dynamic>).map((e) => e as String).toList(),
  addresses: (json['addresses'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ClientToJson(_Client instance) => <String, dynamic>{
  'id': instance.id,
  'tenantId': instance.tenantId,
  'clientCode': instance.clientCode,
  'type': _$ClientTypeEnumMap[instance.type]!,
  'fullName': instance.fullName,
  'status': _$ClientStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'nationalId': instance.nationalId,
  'commercialReg': instance.commercialReg,
  'emails': instance.emails,
  'phones': instance.phones,
  'addresses': instance.addresses,
};

const _$ClientTypeEnumMap = {
  ClientType.individual: 'INDIVIDUAL',
  ClientType.company: 'COMPANY',
  ClientType.unknown: 'unknown',
};

const _$ClientStatusEnumMap = {
  ClientStatus.active: 'ACTIVE',
  ClientStatus.archived: 'ARCHIVED',
  ClientStatus.inactive: 'INACTIVE',
  ClientStatus.unknown: 'unknown',
};
