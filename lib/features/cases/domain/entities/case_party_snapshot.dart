class CaseClientSnapshot {
  const CaseClientSnapshot({
    required this.id,
    required this.clientType,
    required this.name,
    this.nationalId,
    this.registrationNo,
    this.phone,
    this.email,
    this.address,
    this.notes,
  });

  final String id;
  final String clientType;
  final String name;
  final String? nationalId;
  final String? registrationNo;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;

  factory CaseClientSnapshot.fromJson(Map<String, dynamic> json) =>
      CaseClientSnapshot(
        id: json['id'] as String,
        clientType: json['clientType'] as String,
        name: json['name'] as String,
        nationalId: json['nationalId'] as String?,
        registrationNo: json['registrationNo'] as String?,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        address: json['address'] as String?,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'clientType': clientType,
    'name': name,
    'nationalId': nationalId,
    'registrationNo': registrationNo,
    'phone': phone,
    'email': email,
    'address': address,
    'notes': notes,
  };
}

class CaseOpponentSnapshot {
  const CaseOpponentSnapshot({
    required this.id,
    required this.opponentType,
    required this.name,
    this.contact,
    this.representative,
    this.notes,
  });

  final String id;
  final String opponentType;
  final String name;
  final String? contact;
  final String? representative;
  final String? notes;

  factory CaseOpponentSnapshot.fromJson(Map<String, dynamic> json) =>
      CaseOpponentSnapshot(
        id: json['id'] as String,
        opponentType: json['opponentType'] as String,
        name: json['name'] as String,
        contact: json['contact'] as String?,
        representative: json['representative'] as String?,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'opponentType': opponentType,
    'name': name,
    'contact': contact,
    'representative': representative,
    'notes': notes,
  };
}
