import '../../../../core/network/api_result.dart';
import '../entities/task_item.dart';

/// Mirrors API_CONTRACT.md finding I (Tasks) — read-only for M3. No query
/// parameters exist on `GET /tasks`, so `getTasks` fetches the full tenant
/// collection; filtering by `assignedToId` (Dashboard's personal task list)
/// or `caseId` (Case Detail's Tasks section) is done client-side.
abstract class ITaskRepository {
  ApiResult<List<TaskItem>> getTasks();
}
