import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/client_type.dart';

part 'update_client_request.freezed.dart';
part 'update_client_request.g.dart';

/// Request body for `PATCH /clients/{id}` per `UpdateClientDto`
/// (`PartialType(CreateClientDto)` server-side — every field optional).
///
/// Every field is `@JsonKey(includeIfNull: false)` — load-bearing, not
/// decorative: a screen only sets the fields the user actually changed,
/// and freezed's default `toJson()` would otherwise emit every unset field
/// as an explicit `null` key. `ClientsService.update` does a TypeORM
/// `merge(client, updateClientDto)`, which would overwrite untouched
/// columns with `null` if the key is present at all — omitting the key
/// entirely (not just its value) is what makes this a genuine partial
/// PATCH instead of a full-overwrite-with-nulls.
@freezed
abstract class UpdateClientRequest with _$UpdateClientRequest {
  const factory UpdateClientRequest({
    @JsonKey(includeIfNull: false) String? clientCode,
    @JsonKey(includeIfNull: false) ClientType? type,
    @JsonKey(includeIfNull: false) String? fullName,
    @JsonKey(includeIfNull: false) String? nationalId,
    @JsonKey(includeIfNull: false) String? commercialReg,
    @JsonKey(includeIfNull: false) List<String>? emails,
    @JsonKey(includeIfNull: false) List<String>? phones,
    @JsonKey(includeIfNull: false) List<String>? addresses,
  }) = _UpdateClientRequest;

  factory UpdateClientRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateClientRequestFromJson(json);
}
