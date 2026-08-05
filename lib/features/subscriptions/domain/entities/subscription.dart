import 'package:freezed_annotation/freezed_annotation.dart';
import 'subscription_status.dart';

part 'subscription.freezed.dart';
part 'subscription.g.dart';

/// Wire shape for `POST /subscriptions/activate` per API_CONTRACT.md
/// finding M.
///
/// `SubscriptionsController` doesn't apply `plainToInstance` — raw
/// `Subscription` entity. Only the fields this app actually needs are
/// modeled (confirming reactivation worked); `plan`/`billingCycle`/etc.
/// are ignored, same convention as `MyFirm` previously used for
/// `GET /tenants/my-firm`.
@freezed
abstract class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    required String tenantId,
    @JsonKey(unknownEnumValue: SubscriptionStatus.unknown)
    required SubscriptionStatus status,
    required DateTime currentPeriodEnd,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);
}
