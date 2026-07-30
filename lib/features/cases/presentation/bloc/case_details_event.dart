part of 'case_details_bloc.dart';

abstract class CaseDetailsEvent extends Equatable {
  const CaseDetailsEvent();

  @override
  List<Object?> get props => [];
}

class FetchCaseDetailsRequested extends CaseDetailsEvent {
  final String id;
  const FetchCaseDetailsRequested(this.id);

  @override
  List<Object?> get props => [id];
}
