part of 'client_details_bloc.dart';

abstract class ClientDetailsEvent extends Equatable {
  const ClientDetailsEvent();

  @override
  List<Object?> get props => [];
}

class FetchClientDetailsRequested extends ClientDetailsEvent {
  final String id;
  const FetchClientDetailsRequested(this.id);

  @override
  List<Object?> get props => [id];
}
