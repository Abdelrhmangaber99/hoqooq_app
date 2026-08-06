import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/finance/data/models/create_payment_request.dart';
import 'package:hqooq/features/finance/domain/entities/payment.dart';
import 'package:hqooq/features/finance/domain/entities/payment_method.dart';
import 'package:hqooq/features/finance/domain/repository/i_finance_repository.dart';
import 'package:hqooq/features/finance/presentation/bloc/payment_form_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockFinanceRepository extends Mock implements IFinanceRepository {}

void main() {
  late MockFinanceRepository financeRepository;

  final payment = Payment(
    id: 'pay1',
    tenantId: 't1',
    invoiceId: 'inv1',
    amount: 500,
    paymentDate: DateTime(2026, 1, 15),
    method: PaymentMethod.cash,
    createdAt: DateTime(2026, 1, 15),
    updatedAt: DateTime(2026, 1, 15),
  );

  setUpAll(() {
    registerFallbackValue(
      CreatePaymentRequest(
        invoiceId: 'inv1',
        amount: 500,
        paymentDate: DateTime(2026, 1, 15),
        method: PaymentMethod.cash,
      ),
    );
  });

  setUp(() {
    financeRepository = MockFinanceRepository();
  });

  blocTest<PaymentFormBloc, PaymentFormState>(
    'emits [Submitting, Success] on a successful payment',
    build: () {
      when(
        () => financeRepository.createPayment(any()),
      ).thenAnswer((_) async => Right(payment));
      return PaymentFormBloc(financeRepository);
    },
    act: (bloc) => bloc.add(
      PaymentSubmitted(
        CreatePaymentRequest(
          invoiceId: 'inv1',
          amount: 500,
          paymentDate: DateTime(2026, 1, 15),
          method: PaymentMethod.cash,
        ),
      ),
    ),
    expect: () => [PaymentFormSubmitting(), PaymentFormSuccess(payment)],
  );

  blocTest<PaymentFormBloc, PaymentFormState>(
    'emits [Submitting, Failure] when the payment fails',
    build: () {
      when(
        () => financeRepository.createPayment(any()),
      ).thenAnswer((_) async => const Left(ValidationFailure('bad amount')));
      return PaymentFormBloc(financeRepository);
    },
    act: (bloc) => bloc.add(
      PaymentSubmitted(
        CreatePaymentRequest(
          invoiceId: 'inv1',
          amount: -1,
          paymentDate: DateTime(2026, 1, 15),
          method: PaymentMethod.cash,
        ),
      ),
    ),
    expect: () => [
      PaymentFormSubmitting(),
      const PaymentFormFailure('bad amount'),
    ],
  );
}
