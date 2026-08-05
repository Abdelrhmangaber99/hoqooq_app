import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/case_priority.dart';
import '../../domain/entities/case_status.dart';

part 'create_case_request.freezed.dart';
part 'create_case_request.g.dart';

/// Request body for `POST /cases` per `CreateCaseDto`
/// (`Hoqooq-main/src/modules/cases/dtos/create-case.dto.ts`).
///
/// No `tenantId` field — the DTO requires one, but `CaseRepository`
/// injects the current user's tenant id at the wire boundary (same
/// pattern as `ClientRepository.createClient()`) rather than making every
/// caller plumb it through; `CasesService.create` also always overrides
/// whatever's sent with the JWT-derived value regardless.
///
/// No `primaryLawyerId` — that field no longer exists on `CreateCaseDto`
/// or the `Case` entity at all (API_CONTRACT.md finding N). Team
/// membership (including who's the lead lawyer) is a separate call,
/// `POST /cases/:id/assignments`, after the case exists.
///
/// `caseTypeId` was unbrowsable until 2026-08-05 (API_CONTRACT.md finding
/// K added `GET /lookups?kind=CASE_TYPE`) — this is what unblocked case
/// creation in the first place.
@freezed
abstract class CreateCaseRequest with _$CreateCaseRequest {
  const factory CreateCaseRequest({
    required String caseNumber,
    required String clientId,
    required String caseTypeId,
    String? defaultCourtId,
    CaseStatus? status,
    DateTime? openingDate,
    DateTime? closingDate,
    String? outcomeSummary,
    double? agreedFee,
    CasePriority? priority,
  }) = _CreateCaseRequest;

  factory CreateCaseRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCaseRequestFromJson(json);
}
