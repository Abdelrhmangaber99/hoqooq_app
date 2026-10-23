import '../../di/injection.dart';
import '../../features/authentication/presentation/bloc/session_cubit.dart';

/// True iff there's an authenticated session and the current user holds
/// [permissionCode] (`User.hasPerm()`, backed by real `<module>.<action>`
/// codes from `Hoqooq-main /src/core/constants/permissions.constant.ts`).
/// Defaults to `false` on no session — same secure-default direction as
/// `isFirmAdmin`/`agreedFee` gating (BR-026).
///
/// BR-034: this only hides an action from the UI as UX — the backend
/// still enforces the real check, and a 403 is handled regardless (see
/// `ForbiddenFailure`/`ErrorView.isForbidden`).
bool currentUserHasPerm(String permissionCode) {
  final sessionState = getIt<SessionCubit>().state;
  return sessionState is SessionAuthenticated &&
      (sessionState.isFirmAdmin || sessionState.user.hasPerm(permissionCode));
}

/// True when the signed-in account is a firm Employee rather than its admin.
///
/// Employees see only the Cases/Tasks/Hearings that carry a per-Case access
/// grant for them or that they are directly assigned to — the backend's
/// `CasesService.findAll`/`TasksService.findAll`/`HearingsService.findAll`
/// filter every list query this way (PRD v2.0 §5.2, the "effective permission
/// rule"). An Employee list that comes back empty is therefore a normal,
/// expected state that needs explaining, not a failure.
bool currentUserIsEmployee() {
  final sessionState = getIt<SessionCubit>().state;
  return sessionState is SessionAuthenticated &&
      !sessionState.isFirmAdmin &&
      !sessionState.user.isSuperAdmin;
}
