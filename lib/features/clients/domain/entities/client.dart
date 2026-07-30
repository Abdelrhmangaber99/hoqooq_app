import 'package:freezed_annotation/freezed_annotation.dart';
import 'client_status.dart';
import 'client_type.dart';

part 'client.freezed.dart';
part 'client.g.dart';

/// Wire shape for `GET/POST/PATCH /clients` per API_CONTRACT.md §5.
///
/// Rebuilt 2026-07-30 for a backend update: replaces the earlier
/// UI-mockup shape (`name`/`email`/`phone`/`address`/`taxId`/`area`/`info`,
/// none of which the real API ever returned) with the actual fields. Note
/// `emails`/`phones`/`addresses` are plain string arrays with no "primary"
/// flag in any example, unlike the BRD's intent of one designated primary
/// per array — rendered as full lists, not guessing at which is primary
/// (see PLAN.md M2 decision #3).
@freezed
abstract class Client with _$Client {
  const factory Client({
    required String id,
    required String tenantId,
    required String clientCode,
    @JsonKey(unknownEnumValue: ClientType.unknown) required ClientType type,
    required String fullName,
    @JsonKey(unknownEnumValue: ClientStatus.unknown)
    required ClientStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? nationalId,
    String? commercialReg,
    required List<String> emails,
    required List<String> phones,
    required List<String> addresses,
  }) = _Client;

  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);
}
