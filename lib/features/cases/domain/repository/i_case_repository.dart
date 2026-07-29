import '../../../../core/network/api_result.dart';
import '../entities/legal_case.dart';

abstract class ICaseRepository {
  ApiResult<List<LegalCase>> getCases({String? filter});
  ApiResult<LegalCase> getCaseDetails(String id);
}
