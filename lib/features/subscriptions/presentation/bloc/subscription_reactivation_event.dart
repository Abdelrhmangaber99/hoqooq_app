part of 'subscription_reactivation_bloc.dart';

abstract class SubscriptionReactivationEvent extends Equatable {
  const SubscriptionReactivationEvent();

  @override
  List<Object?> get props => [];
}

class SubscriptionReactivationSubmitted extends SubscriptionReactivationEvent {}
