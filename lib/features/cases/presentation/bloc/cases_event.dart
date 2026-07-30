part of 'cases_bloc.dart';

abstract class CasesEvent extends Equatable {
  const CasesEvent();

  @override
  List<Object?> get props => [];
}

class FetchCasesRequested extends CasesEvent {}

/// `null` means "All statuses".
class CasesStatusFilterChanged extends CasesEvent {
  final CaseStatus? status;
  const CasesStatusFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class CasesSearchChanged extends CasesEvent {
  final String query;
  const CasesSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}
