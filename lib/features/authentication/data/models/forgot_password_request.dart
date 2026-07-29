import 'package:freezed_annotation/freezed_annotation.dart';

part 'forgot_password_request.freezed.dart';
part 'forgot_password_request.g.dart';

/// Request body for `POST /auth/forgot-password` per API_CONTRACT.md §1.
@freezed
abstract class ForgotPasswordRequest with _$ForgotPasswordRequest {
  const factory ForgotPasswordRequest({required String email}) =
      _ForgotPasswordRequest;

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestFromJson(json);
}
