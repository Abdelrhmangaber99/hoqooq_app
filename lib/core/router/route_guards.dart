import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../di/injection.dart';
import '../auth/permission_check.dart';
import '../auth/permission_codes.dart';
import '../../features/authentication/presentation/bloc/session_cubit.dart';
import 'app_router.dart';

class RouteGuards {
  static FutureOr<String?> authGuard(
    BuildContext context,
    GoRouterState state,
  ) {
    final sessionState = getIt<SessionCubit>().state;
    final isAuthenticated = sessionState is SessionAuthenticated;
    final isUnknown = sessionState is SessionUnknown;
    final isLoggingIn =
        state.uri.path == AppRouter.login || state.uri.path == AppRouter.splash;

    // Password recovery is reached while signed out (the reset link is
    // followed from an email), so it must not be bounced to the login
    // screen. Kept separate from [isLoggingIn]: an authenticated user is
    // still redirected away from login/splash, but is allowed to sit on
    // the recovery routes.
    final isPublicRecoveryRoute =
        state.uri.path == AppRouter.forgotPassword ||
        state.uri.path == AppRouter.resetPassword ||
        state.uri.path == AppRouter.activate;

    // Cold start with unresolved session state visiting a protected route:
    // Route to splash to allow SessionRestoreRequested to resolve the session,
    // preserving the target destination in queryParameters.
    if (isUnknown && !isLoggingIn && !isPublicRecoveryRoute) {
      final target = state.uri.toString();
      return '${AppRouter.splash}?from=${Uri.encodeComponent(target)}';
    }

    // Unauthenticated user attempting to access a protected route:
    if (!isAuthenticated && !isLoggingIn && !isPublicRecoveryRoute) {
      final target = state.uri.toString();
      return '${AppRouter.login}?from=${Uri.encodeComponent(target)}';
    }

    // Authenticated user arriving at login or splash:
    if (isAuthenticated && isLoggingIn) {
      final from = state.uri.queryParameters['from'];
      if (from != null &&
          from.isNotEmpty &&
          from != AppRouter.login &&
          from != AppRouter.splash) {
        return from;
      }
      return sessionState.user.isSuperAdmin ? AppRouter.firms : AppRouter.home;
    }

    if (isAuthenticated && sessionState.user.isSuperAdmin) {
      final isAllowedSuperAdminPath =
          state.uri.path == AppRouter.provisionFirm ||
          state.uri.path == AppRouter.firms ||
          state.uri.path.startsWith('${AppRouter.firms}/') ||
          state.uri.path == AppRouter.profile;
      if (!isAllowedSuperAdminPath) {
        return AppRouter.firms;
      }
    }

    if (isAuthenticated &&
        !sessionState.user.isSuperAdmin &&
        (state.uri.path.startsWith(AppRouter.firms) ||
            state.uri.path == AppRouter.provisionFirm)) {
      return AppRouter.home;
    }

    if (isAuthenticated &&
        !sessionState.user.isSuperAdmin &&
        state.uri.path.startsWith(AppRouter.cases) &&
        !currentUserHasPerm(PermissionCodes.caseView)) {
      return AppRouter.home;
    }

    if (isAuthenticated &&
        state.uri.path == '${AppRouter.cases}/new' &&
        !sessionState.user.isSuperAdmin &&
        !currentUserHasPerm(PermissionCodes.caseCreate)) {
      return AppRouter.cases;
    }

    if (isAuthenticated &&
        !sessionState.user.isSuperAdmin &&
        state.uri.path.startsWith(AppRouter.clients) &&
        !currentUserHasPerm(PermissionCodes.caseView) &&
        !currentUserHasPerm(PermissionCodes.clientView)) {
      return AppRouter.home;
    }

    if (isAuthenticated &&
        !sessionState.user.isSuperAdmin &&
        state.uri.path.startsWith(AppRouter.calendar) &&
        !currentUserHasPerm(PermissionCodes.calendarRead)) {
      return AppRouter.home;
    }

    if (isAuthenticated &&
        state.uri.path == AppRouter.calendarNew &&
        !currentUserHasPerm(PermissionCodes.calendarManage)) {
      return AppRouter.calendar;
    }

    if (isAuthenticated &&
        state.uri.path.startsWith(AppRouter.hearings) &&
        !currentUserHasPerm(PermissionCodes.hearingView)) {
      return AppRouter.home;
    }

    if (isAuthenticated &&
        state.uri.path.startsWith(AppRouter.tasks) &&
        !currentUserHasPerm(PermissionCodes.taskView)) {
      return AppRouter.home;
    }

    if (isAuthenticated &&
        state.uri.path == AppRouter.tasksNew &&
        !currentUserHasPerm(PermissionCodes.taskCreate)) {
      return AppRouter.tasks;
    }

    if (isAuthenticated &&
        !sessionState.user.isSuperAdmin &&
        state.uri.path.startsWith(AppRouter.finance) &&
        !currentUserHasPerm(PermissionCodes.financeFirmRead)) {
      return AppRouter.home;
    }

    if (isAuthenticated &&
        !sessionState.user.isSuperAdmin &&
        state.uri.path.startsWith(AppRouter.reports) &&
        !currentUserHasPerm(PermissionCodes.financeFirmRead) &&
        !currentUserHasPerm(PermissionCodes.reportOperationalRead)) {
      return AppRouter.home;
    }

    if (isAuthenticated &&
        !sessionState.user.isSuperAdmin &&
        state.uri.path.startsWith(AppRouter.employees) &&
        !sessionState.user.isFirmAdmin &&
        !currentUserHasPerm(PermissionCodes.employeeRead)) {
      return AppRouter.home;
    }

    if (isAuthenticated &&
        state.uri.path == AppRouter.createEmployee &&
        (!sessionState.user.isFirmAdmin ||
            !currentUserHasPerm(PermissionCodes.employeeCreate) ||
            !currentUserHasPerm(PermissionCodes.employeePermissionManage))) {
      return AppRouter.employees;
    }

    if (isAuthenticated &&
        state.uri.path.startsWith('${AppRouter.employees}/') &&
        state.uri.path.endsWith('/edit') &&
        (!sessionState.user.isFirmAdmin ||
            (!currentUserHasPerm(PermissionCodes.employeeEdit) &&
                !currentUserHasPerm(
                  PermissionCodes.employeePermissionManage,
                )))) {
      return AppRouter.employees;
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
