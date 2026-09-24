part of 'case_service_process_bloc.dart';

sealed class CaseServiceProcessState extends Equatable {
  const CaseServiceProcessState();
  @override
  List<Object?> get props => [];
}

class CaseServiceProcessInitial extends CaseServiceProcessState {}

class CaseServiceProcessLoading extends CaseServiceProcessState {}

class CaseServiceProcessLoaded extends CaseServiceProcessState {
  const CaseServiceProcessLoaded(
    this.items, {
    this.cancellingId,
    this.actionError,
  });
  final List<ServiceProcess> items;
  final String? cancellingId;
  final String? actionError;

  CaseServiceProcessLoaded copyWith({
    String? cancellingId,
    String? actionError,
  }) => CaseServiceProcessLoaded(
    items,
    cancellingId: cancellingId,
    actionError: actionError,
  );

  @override
  List<Object?> get props => [items, cancellingId, actionError];
}

class CaseServiceProcessError extends CaseServiceProcessState {
  const CaseServiceProcessError(this.message, {this.isForbidden = false});
  final String message;
  final bool isForbidden;
  @override
  List<Object?> get props => [message, isForbidden];
}
