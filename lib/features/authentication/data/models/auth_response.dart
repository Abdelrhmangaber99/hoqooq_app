import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

/// Response envelope shared by `POST /auth/login`, `POST /auth/signup`, and
/// `POST /auth/refresh` per API_CONTRACT.md §1.
///
/// `user` is deliberately untyped (`Map<String, dynamic>?`) rather than the
/// strict `User` entity: every worked example for these three endpoints in
/// the Postman collection shows `"user": {}` — an empty placeholder, not a
/// confirmed shape. Parsing it strictly as `User` (all fields required)
/// would throw if a real response ever actually sends an empty/partial
/// object here. The app never reads this field — after login/refresh it
/// always calls `GET /users/me` for the authoritative, fully-shaped user
/// (see AuthBloc), so this field is kept only for wire fidelity.
@freezed
abstract class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String accessToken,
    required String refreshToken,
    Map<String, dynamic>? user,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}
