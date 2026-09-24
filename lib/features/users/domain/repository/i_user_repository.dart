import '../../../../core/network/api_result.dart';
import '../../../authentication/domain/entities/user.dart';

/// `GET /users` — real, browsable, DTO-enforced (`plainToInstance`) list of
/// tenant users. Used by M4's write forms for assignee/primary-lawyer
/// pickers (`Task.assignedToId`/`assignedById`, `Case.primaryLawyerId`) —
/// unlike `caseTypeId`/`hearingTypeId`, these reference a real `User`
/// entity with a real list endpoint, not an unbrowsable `Lookup` row.
abstract class IUserRepository {
  ApiResult<List<User>> getUsers();

  /// Tenant-scoped active accounts that can receive Tasks and Case access.
  /// Firm accounts must use `/employees`; `/users` is platform-admin-only.
  ApiResult<List<User>> getAssignableUsers();
}
