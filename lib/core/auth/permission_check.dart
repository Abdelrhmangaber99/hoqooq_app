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
      sessionState.user.hasPerm(permissionCode);
}
