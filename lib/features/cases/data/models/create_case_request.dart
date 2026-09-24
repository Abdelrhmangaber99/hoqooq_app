import '../../domain/entities/case_priority.dart';
import '../../domain/entities/case_status.dart';

/// Request body for `POST /cases` per `CreateCaseDto`
/// (`Hoqooq-main/src/modules/cases/dtos/create-case.dto.ts`).
///
/// Tenant and owner identity are derived by the backend. The Case owns its
/// embedded Client/Opponent snapshots. Court and Circuit selections use the
/// backend reference UUIDs; `courtName` remains a compatibility snapshot.
class CreateCaseRequest {
  const CreateCaseRequest({
    this.caseNumber,
    this.title,
    this.courtCaseNumber,
    this.courtCaseYear,
    this.caseTypeId,
    this.primaryLawyerId,
    required this.client,
    this.opponents = const [],
    this.governorateId,
    this.defaultCourtId,
    this.circuitId,
    this.courtName,
    this.status,
    this.openingDate,
    this.description,
    this.agreedFee,
    this.priority,
  });

  final String? caseNumber;
  final String? title;
  final String? courtCaseNumber;
  final int? courtCaseYear;
  final String? caseTypeId;
  final String? primaryLawyerId;
  final CaseClientInput client;
  final List<CaseOpponentInput> opponents;
  final String? governorateId;
  final String? defaultCourtId;
  final String? circuitId;
  final String? courtName;
  final CaseStatus? status;
  final DateTime? openingDate;
  final String? description;
  final double? agreedFee;
  final CasePriority? priority;

  Map<String, dynamic> toJson() => {
    'caseNumber': caseNumber,
    'title': title,
    'courtCaseNumber': courtCaseNumber,
    'courtCaseYear': courtCaseYear,
    'caseTypeId': caseTypeId,
    'primaryLawyerId': primaryLawyerId,
    'governorateId': governorateId,
    if (defaultCourtId != null) 'defaultCourtId': defaultCourtId,
    if (circuitId != null) 'circuitId': circuitId,
    'courtName': courtName,
    'status': status?.name.toUpperCase(),
    'openingDate': openingDate?.toIso8601String(),
    'client': client.toJson(),
    if (opponents.isNotEmpty)
      'opponents': opponents.map((opponent) => opponent.toJson()).toList(),
    'description': description,
    'agreedFee': agreedFee,
    'priority': priority?.name.toUpperCase(),
  };
}

class CaseClientInput {
  const CaseClientInput({
    required this.clientType,
    required this.name,
    this.nationalId,
    this.registrationNo,
    this.phone,
    this.email,
    this.address,
    this.notes,
  });

  final String clientType;
  final String name;
  final String? nationalId;
  final String? registrationNo;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'clientType': clientType,
    'name': name,
    'nationalId': nationalId,
    'registrationNo': registrationNo,
    'phone': phone,
    'email': email,
    'address': address,
    'notes': notes,
  }..removeWhere((_, value) => value == null);
}

class CaseOpponentInput {
  const CaseOpponentInput({
    required this.opponentType,
    required this.name,
    this.contact,
    this.representative,
    this.notes,
  });

  final String opponentType;
  final String name;
  final String? contact;
  final String? representative;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'opponentType': opponentType,
    'name': name,
    'contact': contact,
    'representative': representative,
    'notes': notes,
  }..removeWhere((_, value) => value == null);
}
