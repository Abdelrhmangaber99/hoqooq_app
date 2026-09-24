part of 'case_meetings_bloc.dart';

sealed class CaseMeetingsState extends Equatable {
  const CaseMeetingsState();
  @override
  List<Object?> get props => [];
}

class CaseMeetingsInitial extends CaseMeetingsState {}

class CaseMeetingsLoading extends CaseMeetingsState {}

class CaseMeetingsLoaded extends CaseMeetingsState {
  const CaseMeetingsLoaded(this.items, {this.actionId, this.actionError});
  final List<ClientMeeting> items;
  final String? actionId;
  final String? actionError;
  CaseMeetingsLoaded copyWith({String? actionId, String? actionError}) =>
      CaseMeetingsLoaded(items, actionId: actionId, actionError: actionError);
  @override
  List<Object?> get props => [items, actionId, actionError];
}

class CaseMeetingsError extends CaseMeetingsState {
  const CaseMeetingsError(this.message, {this.isForbidden = false});
  final String message;
  final bool isForbidden;
  @override
  List<Object?> get props => [message, isForbidden];
}
