import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/client_type.dart';

part 'create_client_request.freezed.dart';
part 'create_client_request.g.dart';

/// Request body for `POST /clients` per `CreateClientDto`
/// (`Hoqooq-main/src/modules/clients/dtos/create-client.dto.ts`).
///
/// Deliberately has no `tenantId` field — the DTO requires one, but
/// `ClientRepository` injects the current user's tenant id at the wire
/// boundary (see its doc comment) rather than making every caller plumb it
/// through. `ValidationPipe`'s `forbidNonWhitelisted` means this must
/// contain exactly `CreateClientDto`'s field set, nothing extra.
@freezed
abstract class CreateClientRequest with _$CreateClientRequest {
  const factory CreateClientRequest({
    required String clientCode,
    required ClientType type,
    required String fullName,
    String? nationalId,
    String? commercialReg,
    List<String>? emails,
    List<String>? phones,
    List<String>? addresses,
  }) = _CreateClientRequest;

  factory CreateClientRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateClientRequestFromJson(json);
}
