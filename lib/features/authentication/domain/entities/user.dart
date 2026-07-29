import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/auth/user_role.dart';

part 'user.freezed.dart';

@freezed
abstract class User with _$User {
  const User._();
  const factory User({
    required String id,
    required String fullName,
    required String email,
    required UserRole role,
    String? lawFirmName,
    String? tenantId,
  }) = _User;
}
