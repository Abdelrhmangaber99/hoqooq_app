import 'package:freezed_annotation/freezed_annotation.dart';

part 'change_password_request.freezed.dart';
part 'change_password_request.g.dart';

/// Request body for `POST /auth/change-password` per API_CONTRACT.md §1.
@freezed
abstract class ChangePasswordRequest with _$ChangePasswordRequest {
  const factory ChangePasswordRequest({
    required String oldPassword,
    required String newPassword,
  }) = _ChangePasswordRequest;

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordRequestFromJson(json);
}
