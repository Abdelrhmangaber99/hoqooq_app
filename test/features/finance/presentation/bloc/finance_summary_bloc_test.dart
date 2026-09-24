import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/finance/domain/entities/case_finance_status.dart';
import 'package:hqooq/features/finance/domain/entities/finance_summary.dart';
import 'package:hqooq/features/finance/domain/repository/i_finance_repository.dart';
import 'package:hqooq/features/finance/presentation/bloc/finance_summary_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockFinanceRepository extends Mock implements IFinanceRepository {}

void main() {
  late MockFinanceRepository repository;

  const testSummary = FinanceSummary(
    totalCaseValue: 10000,
    totalCollected: 4000,
    totalOutstanding: 6000,
    paidCases: 1,
    partialCases: 1,
    unpaidCases: 1,
    cases: [
      CaseFinanceSummaryRow(
        caseId: 'c1',
        caseNumber: 'CAS-101',
        agreedFee: 5000,
        paid: 5000,
        remaining: 0,
        status: CaseFinanceStatus.paid,
      ),
    ],
  );

  setUp(() {
    repository = MockFinanceRepository();
  });

  blocTest<FinanceSummaryBloc, FinanceSummaryState>(
    'emits [Loading, Loaded] on FetchFinanceSummaryRequested success',
    build: () {
      when(() => repository.getSummary())
          .thenAnswer((_) async => const Right(testSummary));
      return FinanceSummaryBloc(repository);
    },
    act: (bloc) => bloc.add(const FetchFinanceSummaryRequested()),
    expect: () => [
      const FinanceSummaryLoading(),
      const FinanceSummaryLoaded(testSummary),
    ],
  );

  blocTest<FinanceSummaryBloc, FinanceSummaryState>(
    'emits [Loading, Error] on FetchFinanceSummaryRequested failure',
    build: () {
      when(() => repository.getSummary()).thenAnswer(
          (_) async => const Left(ServerFailure('Failed to load summary')));
      return FinanceSummaryBloc(repository);
    },
    act: (bloc) => bloc.add(const FetchFinanceSummaryRequested()),
    expect: () => [
      const FinanceSummaryLoading(),
      const FinanceSummaryError(message: 'Failed to load summary'),
    ],
  );
}
