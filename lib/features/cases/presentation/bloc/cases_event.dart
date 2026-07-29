part of 'cases_bloc.dart';

abstract class CasesEvent extends Equatable {
  const CasesEvent();

  @override
  List<Object?> get props => [];
}

class FetchCasesRequested extends CasesEvent {
  final String? filter;
  const FetchCasesRequested({this.filter});

  @override
  List<Object?> get props => [filter];
}
