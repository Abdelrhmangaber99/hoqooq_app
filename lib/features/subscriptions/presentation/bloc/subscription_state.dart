import 'package:equatable/equatable.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial();
}

class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading();
}

class SubscriptionLoaded extends SubscriptionState {
  /// The `/tenants/my-firm` payload — the authoritative firm record
  /// including its versioned `subscriptions[]` history. Single source of
  /// truth for firm name/logo and subscription status everywhere in the
  /// app (settings, subscription page, sidebar workspace name).
  final Map<String, dynamic> firm;
  final Map<String, dynamic>? activeSubscription;
  final List<Map<String, dynamic>> availablePlans;

  /// True while a plan change / activation / deactivation / firm-info save
  /// / logo upload request is in flight. Drives button spinners and
  /// duplicate-submission prevention WITHOUT discarding the currently
  /// displayed data (no full-screen loading flicker).
  final bool isMutating;

  /// Message of the last failed mutation (or refetch). Kept alongside the
  /// loaded data so a failed mutation shows an inline error instead of
  /// wiping the screen — the user can retry from the still-visible state.
  final String? error;

  const SubscriptionLoaded({
    required this.firm,
    required this.activeSubscription,
    required this.availablePlans,
    this.isMutating = false,
    this.error,
  });

  static const Object _unset = Object();

  SubscriptionLoaded copyWith({
    Map<String, dynamic>? firm,
    Map<String, dynamic>? activeSubscription,
    List<Map<String, dynamic>>? availablePlans,
    bool? isMutating,
    Object? error = _unset,
  }) {
    return SubscriptionLoaded(
      firm: firm ?? this.firm,
      activeSubscription: activeSubscription ?? this.activeSubscription,
      availablePlans: availablePlans ?? this.availablePlans,
      isMutating: isMutating ?? this.isMutating,
      error: error == _unset ? this.error : error as String?,
    );
  }

  @override
  List<Object?> get props => [
        firm,
        activeSubscription,
        availablePlans,
        isMutating,
        error,
      ];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}
