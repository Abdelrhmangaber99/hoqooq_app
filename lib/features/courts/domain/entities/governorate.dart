class Governorate {
  const Governorate({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  final String id;
  final String nameEn;
  final String nameAr;

  factory Governorate.fromJson(Map<String, dynamic> json) => Governorate(
    id: json['id'] as String,
    nameEn: json['nameEn'] as String,
    nameAr: json['nameAr'] as String,
  );

  String labelFor(String languageCode) => languageCode == 'ar' ? nameAr : nameEn;
}
