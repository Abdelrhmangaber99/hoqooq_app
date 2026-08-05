import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/hearing_status.dart';

part 'create_hearing_request.freezed.dart';
part 'create_hearing_request.g.dart';

/// Request body for `POST /hearings` per `CreateHearingDto`.
///
/// `hearingTypeId` was unbrowsable until 2026-08-05 — `GET
/// /lookups?kind=HEARING_TYPE` (API_CONTRACT.md finding K) is what
/// unblocked hearing creation. `circuitId` stays unset — `CourtCircuit`
/// still has no controller (finding J, unchanged). No `tenantId` field:
/// `HearingsService.create` derives it from the JWT, never from the
/// request body, so there's nothing to inject at the repository layer
/// here (unlike Cases/Clients, whose DTOs require a client-supplied
/// `tenantId` even though it's overridden server-side).
@freezed
abstract class CreateHearingRequest with _$CreateHearingRequest {
  const factory CreateHearingRequest({
    required String caseId,
    required String courtId,
    required String hearingTypeId,
    required DateTime scheduledAt,
    String? circuitId,
    String? judgeName,
    HearingStatus? status,
    String? outcomeText,
    DateTime? nextHearingAt,
  }) = _CreateHearingRequest;

  factory CreateHearingRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateHearingRequestFromJson(json);
}
