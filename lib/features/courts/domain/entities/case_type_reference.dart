class CaseTypeReference {
  const CaseTypeReference({
    required this.id,
    required this.code,
    required this.labelEn,
    required this.labelAr,
  });

  final String id;
  final String code;
  final String labelEn;
  final String labelAr;

  factory CaseTypeReference.fromJson(Map<String, dynamic> json) =>
      CaseTypeReference(
        id: json['id'] as String,
        code: json['code'] as String,
        labelEn: json['labelEn'] as String,
        labelAr: json['labelAr'] as String,
      );

  String labelFor(String languageCode) =>
      languageCode == 'ar' ? labelAr : labelEn;
}
