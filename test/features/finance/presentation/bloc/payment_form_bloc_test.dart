import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/finance/data/models/create_payment_request.dart';
import 'package:hqooq/features/finance/domain/entities/payment_method.dart';
import 'package:hqooq/features/finance/domain/entities/payment_record.dart';
import 'package:hqooq/features/finance/domain/repository/i_finance_repository.dart';
import 'package:hqooq/features/finance/presentation/bloc/payment_form_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockFinanceRepository extends Mock implements IFinanceRepository {}

void main() {
  late MockFinanceRepository repository;

  final testRecord = PaymentRecord(
    id: 'p1',
    caseId: 'c1',
    amount: 1000,
    paidAt: DateTime(2026, 8, 20),
    method: PaymentMethod.cash,
  );

  const request = CreatePaymentRequest(
    amount: 1000,
    paidAt: '2026-08-20',
    method: PaymentMethod.cash,
  );

  setUp(() {
    repository = MockFinanceRepository();
    registerFallbackValue(request);
  });

  blocTest<PaymentFormBloc, PaymentFormState>(
    'emits [Submitting, Success] on RecordPaymentSubmitted success',
    build: () {
      when(() => repository.recordPayment('c1', request))
          .thenAnswer((_) async => Right(testRecord));
      return PaymentFormBloc(repository);
    },
    act: (bloc) =>
        bloc.add(const RecordPaymentSubmitted(caseId: 'c1', request: request)),
    expect: () => [
      const PaymentFormSubmitting(),
      PaymentFormSuccess(testRecord),
    ],
  );

  blocTest<PaymentFormBloc, PaymentFormState>(
    'emits [Submitting, Success(fromReverse)] on ReversePaymentSubmitted '
    'success',
    build: () {
      when(() => repository.reversePayment('p1', 'Duplicate'))
          .thenAnswer((_) async => Right(testRecord));
      return PaymentFormBloc(repository);
    },
    act: (bloc) => bloc.add(
      const ReversePaymentSubmitted(paymentId: 'p1', reason: 'Duplicate'),
    ),
    expect: () => [
      const PaymentFormSubmitting(),
      PaymentFormSuccess(testRecord, fromReverse: true),
    ],
  );

  blocTest<PaymentFormBloc, PaymentFormState>(
    'flags a 400/422 record rejection as a validation error so the dialog '
    'keeps its entered data',
    build: () {
      when(() => repository.recordPayment('c1', request)).thenAnswer(
        (_) async =>
            const Left(ValidationFailure('amount must not exceed remaining')),
      );
      return PaymentFormBloc(repository);
    },
    act: (bloc) =>
        bloc.add(const RecordPaymentSubmitted(caseId: 'c1', request: request)),
    expect: () => [
      const PaymentFormSubmitting(),
      const PaymentFormError(
        'amount must not exceed remaining',
        isValidationError: true,
      ),
    ],
  );

  blocTest<PaymentFormBloc, PaymentFormState>(
    'flags a 403 record rejection as forbidden so the dialog closes instead '
    'of retrying',
    build: () {
      when(() => repository.recordPayment('c1', request)).thenAnswer(
        (_) async => Left(ForbiddenFailure('Insufficient permissions')),
      );
      return PaymentFormBloc(repository);
    },
    act: (bloc) =>
        bloc.add(const RecordPaymentSubmitted(caseId: 'c1', request: request)),
    expect: () => [
      const PaymentFormSubmitting(),
      const PaymentFormError(
        'Insufficient permissions',
        isForbidden: true,
      ),
    ],
  );

  blocTest<PaymentFormBloc, PaymentFormState>(
    'maps network/server failures into a plain error state',
    build: () {
      when(() => repository.recordPayment('c1', request)).thenAnswer(
        (_) async => const Left(NetworkFailure()),
      );
      return PaymentFormBloc(repository);
    },
    act: (bloc) =>
        bloc.add(const RecordPaymentSubmitted(caseId: 'c1', request: request)),
    expect: () => [
      const PaymentFormSubmitting(),
      const PaymentFormError('No internet connection'),
    ],
  );

  blocTest<PaymentFormBloc, PaymentFormState>(
    'ignores a record submission while one is already in flight',
    build: () {
      // Hold the first call open so the second event genuinely arrives
      // while the handler is still awaiting.
      final gate = Completer<void>();
      when(() => repository.recordPayment('c1', request)).thenAnswer((_) async {
        await gate.future;
        return Right(testRecord);
      });
      return PaymentFormBloc(repository);
    },
    act: (bloc) async {
      bloc.add(const RecordPaymentSubmitted(caseId: 'c1', request: request));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const RecordPaymentSubmitted(caseId: 'c1', request: request));
      await Future<void>.delayed(Duration.zero);
    },
    expect: () => [const PaymentFormSubmitting()],
  );
}
