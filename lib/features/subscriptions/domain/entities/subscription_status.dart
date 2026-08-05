import 'package:json_annotation/json_annotation.dart';

/// `status` on the `Subscription` entity per API_CONTRACT.md finding M.
///
/// Confirmed exhaustive from the actual backend source
/// (`src/modules/subscriptions/entities/subscription.entity.ts`'s
/// `SubscriptionStatus` enum).
enum SubscriptionStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('ACTIVE')
  active,
  @JsonValue('PAST_DUE')
  pastDue,
  @JsonValue('SUSPENDED')
  suspended,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('unknown')
  unknown,
}
