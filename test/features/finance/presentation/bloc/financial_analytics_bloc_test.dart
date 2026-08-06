import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/finance/domain/entities/financial_analytics.dart';
import 'package:hqooq/features/finance/domain/repository/i_finance_repository.dart';
import 'package:hqooq/features/finance/presentation/bloc/financial_analytics_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockFinanceRepository extends Mock implements IFinanceRepository {}

void main() {
  late MockFinanceRepository repository;

  const analytics = FinancialAnalytics(
    totalInvoiced: 125000.5,
    totalPaid: 95000,
    totalOutstanding: 30000.5,
    collectionRatePercentage: 76,
    totalInvoicesCount: 45,
    paidInvoicesCount: 30,
    partialInvoicesCount: 10,
    unpaidInvoicesCount: 5,
    grossRevenue: 95000,
    netProfitEstimate: 95000,
  );

  setUp(() {
    repository = MockFinanceRepository();
  });

  blocTest<FinancialAnalyticsBloc, FinancialAnalyticsState>(
    'emits [Loading, Loaded] on a successful GET /finance/analytics',
    build: () {
      when(
        () => repository.getFinancialAnalytics(),
      ).thenAnswer((_) async => const Right(analytics));
      return FinancialAnalyticsBloc(repository);
    },
    act: (bloc) => bloc.add(FetchFinancialAnalyticsRequested()),
    expect: () => [
      isA<FinancialAnalyticsLoading>(),
      const FinancialAnalyticsLoaded(analytics),
    ],
  );

  blocTest<FinancialAnalyticsBloc, FinancialAnalyticsState>(
    'emits [Loading, Error] when the fetch fails',
    build: () {
      when(
        () => repository.getFinancialAnalytics(),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return FinancialAnalyticsBloc(repository);
    },
    act: (bloc) => bloc.add(FetchFinancialAnalyticsRequested()),
    expect: () => [
      isA<FinancialAnalyticsLoading>(),
      isA<FinancialAnalyticsError>(),
    ],
  );
}
