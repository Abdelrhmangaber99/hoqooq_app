import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/finance/domain/entities/case_financial_summary.dart';
import 'package:hqooq/features/finance/domain/entities/payment_status.dart';
import 'package:hqooq/features/finance/domain/repository/i_finance_repository.dart';
import 'package:hqooq/features/finance/presentation/bloc/cases_financial_summary_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockFinanceRepository extends Mock implements IFinanceRepository {}

void main() {
  late MockFinanceRepository repository;

  const summary = CaseFinancialSummary(
    caseId: 'c1',
    caseNumber: 'CASE-2026-00001',
    clientName: 'Carlos Hernandez',
    totalInvoiced: 15000,
    totalPaid: 10000,
    outstandingBalance: 5000,
    paymentStatus: PaymentStatus.partial,
    invoicesCount: 2,
  );

  setUp(() {
    repository = MockFinanceRepository();
  });

  blocTest<CasesFinancialSummaryBloc, CasesFinancialSummaryState>(
    'emits [Loading, Loaded] on a successful GET /finance/cases-summary',
    build: () {
      when(
        () => repository.getCasesFinancialSummary(),
      ).thenAnswer((_) async => const Right([summary]));
      return CasesFinancialSummaryBloc(repository);
    },
    act: (bloc) => bloc.add(FetchCasesFinancialSummaryRequested()),
    expect: () => [
      isA<CasesFinancialSummaryLoading>(),
      const CasesFinancialSummaryLoaded([summary]),
    ],
  );

  blocTest<CasesFinancialSummaryBloc, CasesFinancialSummaryState>(
    'emits [Loading, Error] when the fetch fails',
    build: () {
      when(
        () => repository.getCasesFinancialSummary(),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return CasesFinancialSummaryBloc(repository);
    },
    act: (bloc) => bloc.add(FetchCasesFinancialSummaryRequested()),
    expect: () => [
      isA<CasesFinancialSummaryLoading>(),
      isA<CasesFinancialSummaryError>(),
    ],
  );
}
