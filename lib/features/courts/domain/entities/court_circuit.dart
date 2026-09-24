class CourtCircuit {
  const CourtCircuit({
    required this.id,
    required this.courtId,
    required this.nameEn,
    required this.nameAr,
  });

  final String id;
  final String courtId;
  final String nameEn;
  final String nameAr;

  factory CourtCircuit.fromJson(Map<String, dynamic> json) => CourtCircuit(
    id: json['id'] as String,
    courtId: json['courtId'] as String,
    nameEn: json['nameEn'] as String,
    nameAr: json['nameAr'] as String,
  );

  String labelFor(String languageCode) => languageCode == 'ar' ? nameAr : nameEn;
}
