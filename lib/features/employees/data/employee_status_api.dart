import 'package:dio/dio.dart';

/// Deactivates an employee's account through the tenant-scoped route
/// `DELETE /employees/:id`.
///
/// **Verified against the deployed API on 2026-10-11** (`GET /api/docs-json`):
/// the previous implementation called `PATCH /employees/:id/status`, which does
/// not exist on the deployed backend — it answers `404` for every caller while
/// `GET/PATCH/DELETE /employees/:id` answer `401` (route present, auth
/// required). Because the edit screen saved the profile *and* this status
/// change as one unit, that 404 aborted every Firm Admin save before
/// `Navigator.pop`, so employees could be created but never updated.
///
/// The deployed contract for the lifecycle is `DELETE /employees/:id`
/// ("Deactivate an Employee and revoke access while retaining history", 204).
/// There is deliberately no reactivation counterpart: the deployed backend has
/// no endpoint that re-activates an archived employee (BE-01 in
/// `BACKEND_V2_FINAL_HANDOFF.md` is still open — Super Admin's
/// `PATCH /users/:id/status` only flips the User row, not the archived Employee
/// profile). Deactivation is therefore one-way from the app.
Future<void> deactivateEmployee(Dio dio, String employeeId) async {
  await dio.delete('/employees/$employeeId');
}
