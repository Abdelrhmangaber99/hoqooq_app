import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../di/injection.dart';
import '../../features/authentication/presentation/bloc/session_cubit.dart';
import 'app_router.dart';

class RouteGuards {
  static FutureOr<String?> authGuard(
    BuildContext context,
    GoRouterState state,
  ) {
    final sessionState = getIt<SessionCubit>().state;
    final isAuthenticated = sessionState is SessionAuthenticated;
    final isSubscriptionInactive = sessionState is SessionSubscriptionInactive;

    final isLoggingIn =
        state.uri.path == AppRouter.login || state.uri.path == AppRouter.splash;
    final isOnSubscriptionInactive =
        state.uri.path == AppRouter.subscriptionInactive;

    // BR-010/012: SubscriptionGuard blocks reads too, so this redirect
    // must win over every other case below — an authenticated user whose
    // subscription just went inactive is still "authenticated" but has
    // nothing reachable except this screen and /subscriptions/*.
    if (isSubscriptionInactive && !isOnSubscriptionInactive) {
      return AppRouter.subscriptionInactive;
    }
    if (!isSubscriptionInactive && isOnSubscriptionInactive) {
      return isAuthenticated ? AppRouter.home : AppRouter.login;
    }

    if (!isAuthenticated && !isSubscriptionInactive && !isLoggingIn) {
      return AppRouter.login;
    }

    if (isAuthenticated && isLoggingIn) {
      return AppRouter.home;
    }

    return null;
  }
}

/// Safely reads `state.extra` as `T`, returning `null` instead of throwing
/// when it's missing or the wrong type. Every `edit` route relies on
/// `context.push(..., extra: someObject)` from in-app navigation — that
/// object is never actually serialized, so an Android process-death +
/// state restoration (or any future deep link into one of these paths)
/// resumes the route with `extra == null`, and a bare `state.extra as X`
/// throws an unhandled `TypeError` instead of failing gracefully.
T? typedExtra<T>(GoRouterState state) {
  final extra = state.extra;
  return extra is T ? extra : null;
}
