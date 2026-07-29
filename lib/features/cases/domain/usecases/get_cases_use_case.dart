import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../entities/legal_case.dart';
import '../repository/i_case_repository.dart';

@lazySingleton
class GetCasesUseCase {
  final ICaseRepository repository;

  GetCasesUseCase(this.repository);

  ApiResult<List<LegalCase>> execute({String? filter}) {
    return repository.getCases(filter: filter);
  }
}
