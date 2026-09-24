part of 'cases_bloc.dart';

abstract class CasesState extends Equatable {
  const CasesState();

  @override
  List<Object?> get props => [];
}

class CasesInitial extends CasesState {}

class CasesLoading extends CasesState {}

/// Zero-results is represented by an empty `cases` list here — the list
/// screen decides whether to show the `EmptyState` widget, rather than a
/// separate bloc state, since it's the same "loaded" data shape either way.
class CasesLoaded extends CasesState {
  final List<LegalCase> cases;
  final CaseStatus? statusFilter;
  final String searchQuery;
  final int totalCount;
  final Map<CaseStatus, int> statusCounts;

  const CasesLoaded(
    this.cases, {
    this.statusFilter,
    this.searchQuery = '',
    this.totalCount = 0,
    this.statusCounts = const {},
  });

  @override
  List<Object?> get props => [
    cases,
    statusFilter,
    searchQuery,
    totalCount,
    statusCounts,
  ];
}

class CasesError extends CasesState {
  final String message;
  final bool isForbidden;
  const CasesError(this.message, {this.isForbidden = false});

  @override
  List<Object?> get props => [message, isForbidden];
}
