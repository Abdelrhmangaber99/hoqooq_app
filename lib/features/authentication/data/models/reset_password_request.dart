import 'package:freezed_annotation/freezed_annotation.dart';

part 'reset_password_request.freezed.dart';
part 'reset_password_request.g.dart';

/// Request body for `POST /auth/reset-password` per API_CONTRACT.md §1.
@freezed
abstract class ResetPasswordRequest with _$ResetPasswordRequest {
  const factory ResetPasswordRequest({
    required String token,
    required String newPassword,
  }) = _ResetPasswordRequest;

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestFromJson(json);
}
