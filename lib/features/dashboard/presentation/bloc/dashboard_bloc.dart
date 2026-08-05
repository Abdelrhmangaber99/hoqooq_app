import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../authentication/presentation/bloc/session_cubit.dart';
import '../../../tasks/domain/entities/task_item.dart';
import '../../../tasks/domain/entities/task_status.dart';
import '../../../tasks/domain/repository/i_task_repository.dart';
import '../../domain/entities/dashboard_metrics.dart';
import '../../domain/repository/i_dashboard_repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

/// Real data for the Dashboard screen, replacing its previous 100%-static
/// mock content. `GET /tasks` has no `?assignedToId=` filter
/// (API_CONTRACT.md finding I), so the personal pending-tasks list is
/// fetched in full and filtered client-side to the current user (read from
/// `SessionCubit`) and to `PENDING`/`IN_PROGRESS` status.
@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final IDashboardRepository _dashboardRepository;
  final ITaskRepository _taskRepository;
  final SessionCubit _sessionCubit;

  DashboardBloc(
    this._dashboardRepository,
    this._taskRepository,
    this._sessionCubit,
  ) : super(DashboardInitial()) {
    on<FetchDashboardRequested>(_onFetch);
  }

  Future<void> _onFetch(
    FetchDashboardRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    final metricsResult = await _dashboardRepository.getMetrics();
    await metricsResult.fold(
      (failure) async => emit(
        DashboardError(
          failure.message,
          isForbidden: failure is ForbiddenFailure,
        ),
      ),
      (metrics) async {
        final sessionState = _sessionCubit.state;
        final currentUserId = sessionState is SessionAuthenticated
            ? sessionState.user.id
            : null;

        final tasksResult = await _taskRepository.getTasks();
        // A failed secondary fetch doesn't fail the whole screen — same
        // precedent as M2's ClientDetailsBloc degrading to an empty list.
        final pendingTasks = tasksResult.fold(
          (_) => const <TaskItem>[],
          (allTasks) => allTasks
              .where(
                (t) =>
                    t.assignedToId == currentUserId &&
                    (t.status == TaskStatus.pending ||
                        t.status == TaskStatus.inProgress),
              )
              .toList(),
        );

        emit(DashboardLoaded(metrics, pendingTasks));
      },
    );
  }
}
