part of 'client_details_bloc.dart';

abstract class ClientDetailsState extends Equatable {
  const ClientDetailsState();

  @override
  List<Object?> get props => [];
}

class ClientDetailsInitial extends ClientDetailsState {}

class ClientDetailsLoading extends ClientDetailsState {}

class ClientDetailsLoaded extends ClientDetailsState {
  final Client client;

  /// This client's cases, found by fetching all cases and filtering
  /// client-side by `clientId` (see the bloc's doc comment). Empty if the
  /// cases fetch failed — a secondary-section failure doesn't fail the
  /// whole screen.
  final List<LegalCase> cases;

  const ClientDetailsLoaded(this.client, this.cases);

  @override
  List<Object?> get props => [client, cases];
}

class ClientDetailsError extends ClientDetailsState {
  final String message;
  const ClientDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
