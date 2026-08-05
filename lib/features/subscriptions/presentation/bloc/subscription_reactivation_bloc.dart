import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repository/i_subscription_repository.dart';

part 'subscription_reactivation_event.dart';
part 'subscription_reactivation_state.dart';

/// Powers the "Reactivate" action on the subscription-blocked screen
/// (`FIRM_ADMIN` only — see that screen's doc comment). Deliberately
/// doesn't touch `SessionCubit` itself — the page's `BlocListener` calls
/// `SessionCubit.subscriptionReactivated()` on success, keeping this bloc
/// consistent with every other write bloc in the app (never reaches past
/// its own repository).
@injectable
class SubscriptionReactivationBloc
    extends Bloc<SubscriptionReactivationEvent, SubscriptionReactivationState> {
  final ISubscriptionRepository _subscriptionRepository;

  SubscriptionReactivationBloc(this._subscriptionRepository)
    : super(SubscriptionReactivationInitial()) {
    on<SubscriptionReactivationSubmitted>(_onSubmit);
  }

  Future<void> _onSubmit(
    SubscriptionReactivationSubmitted event,
    Emitter<SubscriptionReactivationState> emit,
  ) async {
    emit(SubscriptionReactivationSubmitting());
    final result = await _subscriptionRepository.activateSubscription();
    result.fold(
      (failure) => emit(SubscriptionReactivationFailure(failure.message)),
      (subscription) => emit(SubscriptionReactivationSuccess(subscription)),
    );
  }
}
