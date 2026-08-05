part of 'subscription_reactivation_bloc.dart';

abstract class SubscriptionReactivationState extends Equatable {
  const SubscriptionReactivationState();

  @override
  List<Object?> get props => [];
}

class SubscriptionReactivationInitial extends SubscriptionReactivationState {}

class SubscriptionReactivationSubmitting
    extends SubscriptionReactivationState {}

class SubscriptionReactivationSuccess extends SubscriptionReactivationState {
  final Subscription subscription;
  const SubscriptionReactivationSuccess(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class SubscriptionReactivationFailure extends SubscriptionReactivationState {
  final String message;
  const SubscriptionReactivationFailure(this.message);

  @override
  List<Object?> get props => [message];
}
