import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/cases/domain/repository/i_case_repository.dart';
import 'package:hqooq/features/cases/presentation/bloc/case_team_assignment_bloc.dart';
import 'package:hqooq/features/users/domain/repository/i_user_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockCaseRepository extends Mock implements ICaseRepository {}

class MockUserRepository extends Mock implements IUserRepository {}

void main() {
  late MockCaseRepository caseRepository;
  late MockUserRepository userRepository;

  final employee = User(
    id: 'employee-1',
    email: 'employee@firm.com',
    fullName: 'Mona Ali',
    status: 'ACTIVE',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    accountType: 'EMPLOYEE',
  );

  setUp(() {
    caseRepository = MockCaseRepository();
    userRepository = MockUserRepository();
  });

  blocTest<CaseTeamAssignmentBloc, CaseTeamAssignmentState>(
    'loads employees created in the current firm account',
    setUp: () {
      when(
        () => userRepository.getAssignableUsers(),
      ).thenAnswer((_) async => Right([employee]));
    },
    build: () => CaseTeamAssignmentBloc(caseRepository, userRepository),
    act: (bloc) => bloc.add(LoadCaseTeamAssignmentReferenceDataRequested()),
    expect: () => [
      isA<CaseTeamAssignmentLoading>(),
      isA<CaseTeamAssignmentReady>().having((state) => state.users, 'users', [
        employee,
      ]),
    ],
    verify: (_) {
      verify(() => userRepository.getAssignableUsers()).called(1);
      verifyNever(() => userRepository.getUsers());
    },
  );
}
