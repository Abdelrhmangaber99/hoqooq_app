import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../di/injection.dart';
import '../../features/authentication/domain/repository/i_auth_repository.dart';
import 'app_router.dart';

class RouteGuards {
  static FutureOr<String?> authGuard(BuildContext context, GoRouterState state) async {
    final authRepo = getIt<IAuthRepository>();
    final userResult = await authRepo.getCurrentUser();
    
    bool isAuthenticated = false;
    userResult.fold((_) => isAuthenticated = false, (user) => isAuthenticated = user != null);

    final isLoggingIn = state.uri.path == AppRouter.login || 
                        state.uri.path == AppRouter.signUp || 
                        state.uri.path == AppRouter.splash;

    if (!isAuthenticated && !isLoggingIn) {
      return AppRouter.login;
    }

    if (isAuthenticated && isLoggingIn) {
      return AppRouter.home;
    }

    return null;
  }
}
