// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_client_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateClientRequest _$UpdateClientRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateClientRequest(
  clientCode: json['clientCode'] as String?,
  type: $enumDecodeNullable(_$ClientTypeEnumMap, json['type']),
  fullName: json['fullName'] as String?,
  nationalId: json['nationalId'] as String?,
  commercialReg: json['commercialReg'] as String?,
  emails: (json['emails'] as List<dynamic>?)?.map((e) => e as String).toList(),
  phones: (json['phones'] as List<dynamic>?)?.map((e) => e as String).toList(),
  addresses: (json['addresses'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$UpdateClientRequestToJson(
  _UpdateClientRequest instance,
) => <String, dynamic>{
  'clientCode': ?instance.clientCode,
  'type': ?_$ClientTypeEnumMap[instance.type],
  'fullName': ?instance.fullName,
  'nationalId': ?instance.nationalId,
  'commercialReg': ?instance.commercialReg,
  'emails': ?instance.emails,
  'phones': ?instance.phones,
  'addresses': ?instance.addresses,
};

const _$ClientTypeEnumMap = {
  ClientType.individual: 'INDIVIDUAL',
  ClientType.company: 'COMPANY',
  ClientType.unknown: 'unknown',
};
