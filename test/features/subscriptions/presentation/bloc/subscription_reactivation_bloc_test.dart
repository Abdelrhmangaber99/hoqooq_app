import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/subscriptions/domain/entities/subscription.dart';
import 'package:hqooq/features/subscriptions/domain/entities/subscription_status.dart';
import 'package:hqooq/features/subscriptions/domain/repository/i_subscription_repository.dart';
import 'package:hqooq/features/subscriptions/presentation/bloc/subscription_reactivation_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockSubscriptionRepository extends Mock
    implements ISubscriptionRepository {}

void main() {
  late MockSubscriptionRepository subscriptionRepository;

  final subscription = Subscription(
    id: 'sub1',
    tenantId: 't1',
    status: SubscriptionStatus.active,
    currentPeriodEnd: DateTime(2026, 9, 5),
  );

  setUp(() {
    subscriptionRepository = MockSubscriptionRepository();
  });

  blocTest<SubscriptionReactivationBloc, SubscriptionReactivationState>(
    'emits [Submitting, Success] on a successful reactivation',
    build: () {
      when(
        () => subscriptionRepository.activateSubscription(),
      ).thenAnswer((_) async => Right(subscription));
      return SubscriptionReactivationBloc(subscriptionRepository);
    },
    act: (bloc) => bloc.add(SubscriptionReactivationSubmitted()),
    expect: () => [
      isA<SubscriptionReactivationSubmitting>(),
      SubscriptionReactivationSuccess(subscription),
    ],
  );

  blocTest<SubscriptionReactivationBloc, SubscriptionReactivationState>(
    'emits [Submitting, Failure] when reactivation fails (e.g. no '
    'subscription row exists for this tenant)',
    build: () {
      when(() => subscriptionRepository.activateSubscription()).thenAnswer(
        (_) async =>
            const Left(ServerFailure('Subscription not found for tenant')),
      );
      return SubscriptionReactivationBloc(subscriptionRepository);
    },
    act: (bloc) => bloc.add(SubscriptionReactivationSubmitted()),
    expect: () => [
      isA<SubscriptionReactivationSubmitting>(),
      const SubscriptionReactivationFailure(
        'Subscription not found for tenant',
      ),
    ],
  );
}
