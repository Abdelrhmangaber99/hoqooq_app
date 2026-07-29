import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../di/injection.dart';
import '../../features/authentication/presentation/bloc/session_cubit.dart';
import 'app_router.dart';

class RouteGuards {
  static FutureOr<String?> authGuard(BuildContext context, GoRouterState state) {
    final sessionState = getIt<SessionCubit>().state;
    final isAuthenticated = sessionState is SessionAuthenticated;

    final isLoggingIn =
        state.uri.path == AppRouter.login || state.uri.path == AppRouter.splash;

    if (!isAuthenticated && !isLoggingIn) {
      return AppRouter.login;
    }

    if (isAuthenticated && isLoggingIn) {
      return AppRouter.home;
    }

    return null;
  }
}
