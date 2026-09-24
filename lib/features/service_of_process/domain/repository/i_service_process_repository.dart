import '../../../../core/network/api_result.dart';
import '../../data/models/create_service_process_request.dart';
import '../../data/models/complete_service_process_request.dart';
import '../../data/models/update_service_process_request.dart';
import '../entities/service_process.dart';

abstract class IServiceProcessRepository {
  ApiResult<List<ServiceProcess>> getForCase(String caseId);
  ApiResult<ServiceProcess> create(CreateServiceProcessRequest request);
  ApiResult<ServiceProcess> update(
    String id,
    UpdateServiceProcessRequest request,
  );
  ApiResult<ServiceProcess> complete(
    String id,
    CompleteServiceProcessRequest request,
  );
  ApiResult<void> cancel(String id);
}
