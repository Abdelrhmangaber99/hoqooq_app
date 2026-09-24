import '../../../../core/network/api_result.dart';
import '../../data/models/create_task_request.dart';
import '../../data/models/update_task_request.dart';
import '../entities/task_item.dart';

/// Mirrors API_CONTRACT.md finding I (Tasks). No query parameters exist on
/// `GET /tasks`, so `getTasks` fetches the full tenant collection;
/// filtering by `assignedToId` (Dashboard's personal task list) is done
/// client-side.
///
/// `createTask`/`updateTask` added in M4 — no `Lookup` dependency at all,
/// unlike Cases/Hearings creation: `assignedById`/`assignedToId` reference
/// the real, browsable `User` entity.
abstract class ITaskRepository {
  ApiResult<List<TaskItem>> getTasks();
  ApiResult<TaskItem> createTask(CreateTaskRequest request);
  ApiResult<TaskItem> updateTask(String id, UpdateTaskRequest request);
  ApiResult<TaskItem> completeTask(String id, String completionNote);
  ApiResult<void> cancelTask(String id);
}
