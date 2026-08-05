import '../../../../core/network/api_result.dart';
import '../entities/subscription.dart';

/// `POST /subscriptions/activate` per API_CONTRACT.md finding M — a
/// no-real-payment "simulate successful payment" reactivation for the
/// caller's own tenant (defaults `tenantId` to the JWT's on the backend
/// when the body omits it). Only works if a `Subscription` row already
/// exists for the tenant (404 otherwise — only reachable for an account
/// that never went through `/auth/signup`, e.g. the seeded super-admin,
/// which is exempt from `SubscriptionGuard` anyway since it has no
/// `tenantId`). Bearer-only; no special permission required beyond being
/// authenticated as this tenant's user.
abstract class ISubscriptionRepository {
  ApiResult<Subscription> activateSubscription();
}
