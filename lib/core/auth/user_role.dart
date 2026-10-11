enum UserRole {
  client,
  lawyer,
  firmOwner,
  secretary,
  assistant,
  accountant,
  hr,
  platformAdmin;

  String get name => toString().split('.').last;

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.name == role,
      orElse: () => UserRole.client,
    );
  }
}

class PermissionManager {
  final UserRole role;

  PermissionManager(this.role);

  bool get canViewFinance => [
    UserRole.firmOwner,
    UserRole.accountant,
    UserRole.platformAdmin,
  ].contains(role);

  bool get canManageEmployees => [
    UserRole.firmOwner,
    UserRole.hr,
  ].contains(role);

  bool get canEditCases => [
    UserRole.firmOwner,
    UserRole.lawyer,
  ].contains(role);

  bool get isClient => role == UserRole.client;
  bool get isLawyer => role == UserRole.lawyer;
  bool get isFirmStaff => role != UserRole.client && role != UserRole.platformAdmin;
}
