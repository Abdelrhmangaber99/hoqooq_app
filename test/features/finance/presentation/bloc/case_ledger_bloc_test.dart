import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/finance/domain/entities/case_finance_detail.dart';
import 'package:hqooq/features/finance/domain/repository/i_finance_repository.dart';
import 'package:hqooq/features/finance/presentation/bloc/case_ledger_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockFinanceRepository extends Mock implements IFinanceRepository {}

void main() {
  late MockFinanceRepository repository;

  const testDetail = CaseFinanceDetail(
    caseId: 'c1',
    agreedFee: 5000,
    payments: [],
  );

  setUp(() {
    repository = MockFinanceRepository();
  });

  blocTest<CaseLedgerBloc, CaseLedgerState>(
    'emits [Loading, Loaded] on FetchCaseLedgerRequested success',
    build: () {
      when(
        () => repository.getCaseFinance('c1'),
      ).thenAnswer((_) async => const Right(testDetail));
      return CaseLedgerBloc(repository);
    },
    act: (bloc) => bloc.add(const FetchCaseLedgerRequested('c1')),
    expect: () => [
      const CaseLedgerLoading(),
      const CaseLedgerLoaded(testDetail),
    ],
  );

  blocTest<CaseLedgerBloc, CaseLedgerState>(
    'emits [Loading, Error] on FetchCaseLedgerRequested failure',
    build: () {
      when(() => repository.getCaseFinance('c1')).thenAnswer(
        (_) async => const Left(ServerFailure('Failed to load ledger')),
      );
      return CaseLedgerBloc(repository);
    },
    act: (bloc) => bloc.add(const FetchCaseLedgerRequested('c1')),
    expect: () => [
      const CaseLedgerLoading(),
      const CaseLedgerError(message: 'Failed to load ledger'),
    ],
  );

  blocTest<CaseLedgerBloc, CaseLedgerState>(
    'flags a 403 fetch failure as forbidden so the UI hides retry',
    build: () {
      when(() => repository.getCaseFinance('c1')).thenAnswer(
        (_) async => Left(ForbiddenFailure('Insufficient permissions')),
      );
      return CaseLedgerBloc(repository);
    },
    act: (bloc) => bloc.add(const FetchCaseLedgerRequested('c1')),
    expect: () => [
      const CaseLedgerLoading(),
      const CaseLedgerError(
        message: 'Insufficient permissions',
        isForbidden: true,
      ),
    ],
  );

  // The agreed-fee update flow was removed with the client-side writer:
  // `PATCH /finance/cases/:id/agreed-fee` does not exist on the backend, so
  // the bloc has no such event any more and there is nothing to assert here.
}
