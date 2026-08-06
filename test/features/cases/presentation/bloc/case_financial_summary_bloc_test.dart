import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/cases/presentation/bloc/case_financial_summary_bloc.dart';
import 'package:hqooq/features/finance/domain/entities/payment_status.dart';
import 'package:hqooq/features/finance/domain/entities/single_case_financial_detail.dart';
import 'package:hqooq/features/finance/domain/repository/i_finance_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockFinanceRepository extends Mock implements IFinanceRepository {}

void main() {
  late MockFinanceRepository repository;

  const summary = SingleCaseFinancialDetail(
    caseId: 'c1',
    caseNumber: 'CASE-2026-00001',
    clientName: 'Carlos Hernandez',
    totalInvoiced: 15000,
    totalPaid: 10000,
    outstandingBalance: 5000,
    paymentStatus: PaymentStatus.partial,
    invoices: [],
  );

  setUp(() {
    repository = MockFinanceRepository();
  });

  blocTest<CaseFinancialSummaryBloc, CaseFinancialSummaryState>(
    'emits [Loading, Loaded] on a successful GET '
    '/finance/cases/{id}/summary',
    build: () {
      when(
        () => repository.getCaseFinancialSummary('c1'),
      ).thenAnswer((_) async => const Right(summary));
      return CaseFinancialSummaryBloc(repository);
    },
    act: (bloc) => bloc.add(const FetchCaseFinancialSummaryRequested('c1')),
    expect: () => [
      isA<CaseFinancialSummaryLoading>(),
      const CaseFinancialSummaryLoaded(summary),
    ],
  );

  blocTest<CaseFinancialSummaryBloc, CaseFinancialSummaryState>(
    'emits [Loading, Error] when the fetch fails',
    build: () {
      when(
        () => repository.getCaseFinancialSummary('c1'),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return CaseFinancialSummaryBloc(repository);
    },
    act: (bloc) => bloc.add(const FetchCaseFinancialSummaryRequested('c1')),
    expect: () => [
      isA<CaseFinancialSummaryLoading>(),
      isA<CaseFinancialSummaryError>(),
    ],
  );
}
