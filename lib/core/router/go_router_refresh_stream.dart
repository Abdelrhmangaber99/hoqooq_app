import 'dart:async';
import 'package:flutter/foundation.dart';

/// Adapts a `Stream` into a `Listenable` for `GoRouter`'s
/// `refreshListenable`. Without this, `RouteGuards.authGuard` only
/// re-evaluates on the next user-initiated navigation — fine for the
/// existing 401 case (a failed fetch already leaves the user looking at
/// an error state they'll naturally navigate away from), but not good
/// enough for `SessionSubscriptionInactive` (BR-010/012): the backend's
/// `SubscriptionGuard` blocks reads too, so a user sitting on a screen
/// that just 402'd needs to land on the blocking screen immediately, not
/// only whenever they next happen to tap something.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
