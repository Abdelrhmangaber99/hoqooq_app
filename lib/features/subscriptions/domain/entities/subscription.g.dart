// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Subscription _$SubscriptionFromJson(Map<String, dynamic> json) =>
    _Subscription(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      status: $enumDecode(
        _$SubscriptionStatusEnumMap,
        json['status'],
        unknownValue: SubscriptionStatus.unknown,
      ),
      currentPeriodEnd: DateTime.parse(json['currentPeriodEnd'] as String),
    );

Map<String, dynamic> _$SubscriptionToJson(_Subscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'status': _$SubscriptionStatusEnumMap[instance.status]!,
      'currentPeriodEnd': instance.currentPeriodEnd.toIso8601String(),
    };

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.pending: 'PENDING',
  SubscriptionStatus.active: 'ACTIVE',
  SubscriptionStatus.pastDue: 'PAST_DUE',
  SubscriptionStatus.suspended: 'SUSPENDED',
  SubscriptionStatus.cancelled: 'CANCELLED',
  SubscriptionStatus.unknown: 'unknown',
};
