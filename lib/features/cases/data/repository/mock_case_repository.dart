import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/legal_case.dart';
import '../../domain/repository/i_case_repository.dart';

@LazySingleton(as: ICaseRepository)
class MockCaseRepository implements ICaseRepository {
  @override
  ApiResult<List<LegalCase>> getCases({String? filter}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Right([
      LegalCase(
        id: '1',
        title: 'Hernandez v. State',
        caseNumber: '#2026-CR-4471',
        attorneyName: 'Atty. James Reynolds',
        status: 'Active',
        category: 'Criminal Defense',
        hearingsCount: 3,
        documentsCount: 7,
        daysOpen: 26,
      ),
    ]);
  }

  @override
  ApiResult<LegalCase> getCaseDetails(String id) async {
    return Right(LegalCase(
      id: id,
      title: 'Hernandez v. State',
      caseNumber: '#2026-CR-4471',
      attorneyName: 'Atty. James Reynolds',
      status: 'Active',
      category: 'Criminal Defense',
      hearingsCount: 3,
      documentsCount: 7,
      daysOpen: 26,
    ));
  }
}
