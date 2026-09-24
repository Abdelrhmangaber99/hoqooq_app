import 'dart:async';
import 'package:flutter/foundation.dart';
import '../router/app_router.dart';
import '../../features/authentication/presentation/bloc/session_cubit.dart';

/// Adapts a `Stream` into a `Listenable` for `GoRouter`'s
/// `refreshListenable`, so `RouteGuards.authGuard` re-evaluates the moment
/// `SessionCubit` changes (e.g. a 401-triggered logout) instead of only on
/// the next user-initiated navigation.
///
/// When the session becomes [SessionUnauthenticated], any open dialog or
/// bottom-sheet on the root navigator is dismissed so the login redirect
/// is not blocked by a stale overlay.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((event) {
      if (event is SessionUnauthenticated) {
        final nav = AppRouter.rootNavigatorKey.currentState;
        if (nav != null && nav.canPop()) {
          nav.popUntil((route) => route.isFirst);
        }
      }
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
