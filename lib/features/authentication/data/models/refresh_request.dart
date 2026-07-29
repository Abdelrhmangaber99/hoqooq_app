import 'package:freezed_annotation/freezed_annotation.dart';

part 'refresh_request.freezed.dart';
part 'refresh_request.g.dart';

/// Request body for `POST /auth/refresh` per API_CONTRACT.md §1.
@freezed
abstract class RefreshRequest with _$RefreshRequest {
  const factory RefreshRequest({required String refreshToken}) =
      _RefreshRequest;

  factory RefreshRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshRequestFromJson(json);
}
