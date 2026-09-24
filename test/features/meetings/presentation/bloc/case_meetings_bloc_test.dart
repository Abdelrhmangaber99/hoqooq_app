import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/meetings/domain/entities/client_meeting.dart';
import 'package:hqooq/features/meetings/domain/entities/meeting_status.dart';
import 'package:hqooq/features/meetings/domain/repository/i_meeting_repository.dart';
import 'package:hqooq/features/meetings/presentation/bloc/case_meetings_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockMeetingRepository extends Mock implements IMeetingRepository {}

void main() {
  late MockMeetingRepository repository;
  final meeting = ClientMeeting(
    id: 'm1',
    caseId: 'c1',
    scheduledAt: DateTime(2026, 9, 10),
    locationOrMethod: 'Office',
    subject: 'Case update',
    status: MeetingStatus.scheduled,
    createdAt: DateTime(2026, 8, 17),
    updatedAt: DateTime(2026, 8, 17),
  );
  final other = ClientMeeting(
    id: 'm2',
    caseId: 'c2',
    scheduledAt: DateTime(2026, 9, 11),
    locationOrMethod: 'Call',
    subject: 'Other',
    status: MeetingStatus.scheduled,
    createdAt: DateTime(2026, 8, 17),
    updatedAt: DateTime(2026, 8, 17),
  );
  setUp(() => repository = MockMeetingRepository());

  blocTest<CaseMeetingsBloc, CaseMeetingsState>(
    'filters the tenant meeting list to the current Case',
    build: () {
      when(
        () => repository.getMeetings(),
      ).thenAnswer((_) async => Right([meeting, other]));
      return CaseMeetingsBloc(repository);
    },
    act: (bloc) => bloc.add(const FetchCaseMeetingsRequested('c1')),
    expect: () => [
      CaseMeetingsLoading(),
      CaseMeetingsLoaded([meeting]),
    ],
  );

  blocTest<CaseMeetingsBloc, CaseMeetingsState>(
    'completes then refreshes the Case meeting list',
    build: () {
      final completed = ClientMeeting(
        id: 'm1',
        caseId: 'c1',
        scheduledAt: DateTime(2026, 9, 10),
        locationOrMethod: 'Office',
        subject: 'Case update',
        status: MeetingStatus.completed,
        outcomeNotes: 'Approved',
        createdAt: DateTime(2026, 8, 17),
        updatedAt: DateTime(2026, 9, 10),
      );
      when(
        () => repository.complete('m1', 'Approved'),
      ).thenAnswer((_) async => Right(completed));
      when(
        () => repository.getMeetings(),
      ).thenAnswer((_) async => Right([completed]));
      return CaseMeetingsBloc(repository);
    },
    seed: () => CaseMeetingsLoaded([meeting]),
    act: (bloc) => bloc.add(
      const CompleteMeetingRequested(
        id: 'm1',
        caseId: 'c1',
        outcomeNotes: 'Approved',
      ),
    ),
    expect: () => [
      CaseMeetingsLoaded([meeting], actionId: 'm1'),
      isA<CaseMeetingsLoaded>().having(
        (state) => state.items.single.status,
        'status',
        MeetingStatus.completed,
      ),
    ],
  );
}
