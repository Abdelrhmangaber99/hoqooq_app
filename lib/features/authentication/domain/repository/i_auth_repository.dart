import '../../../../core/network/api_result.dart';
import '../../data/models/auth_response.dart';
import '../entities/my_firm.dart';
import '../entities/user.dart';

/// Mirrors API_CONTRACT.md §1 (Auth) — the endpoints M1/M2 need. `POST
/// /auth/signup` is intentionally not exposed here: BR-001 forbids public
/// self-registration in v1, so the mobile app has no reachable path that
/// should ever call it (see CLAUDE.md / PLAN.md sign-up decision).
abstract class IAuthRepository {
  ApiResult<AuthResponse> login({
    required String email,
    required String password,
  });

  ApiResult<AuthResponse> refresh({required String refreshToken});

  ApiResult<void> logout({required String refreshToken});

  ApiResult<User> getCurrentUser();

  /// `GET /tenants/my-firm` — used only to derive `isFirmAdmin`
  /// (`ownerUserId == user.id`, see `MyFirm`'s doc comment). Not a general
  /// firm-profile fetch; no firm-settings screen exists yet.
  ApiResult<MyFirm> getMyFirm();

  ApiResult<void> forgotPassword({required String email});

  ApiResult<void> resetPassword({
    required String token,
    required String newPassword,
  });

  ApiResult<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}
