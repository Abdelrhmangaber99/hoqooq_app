import 'package:freezed_annotation/freezed_annotation.dart';

part 'court.freezed.dart';
part 'court.g.dart';

/// Backend Court reference used by Hearing and reference-data workflows.
/// Case forms no longer use this entity; they persist a Google-selected Court
/// display name instead.
@freezed
abstract class Court with _$Court {
  const factory Court({
    required String id,
    required String name,
    String? nameEn,
    String? nameAr,
    required String type,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? city,
    String? address,
  }) = _Court;

  factory Court.fromJson(Map<String, dynamic> json) => _$CourtFromJson({
    ...json,
    'name': json['name'] ?? json['nameEn'] ?? json['nameAr'] ?? '',
    'nameEn': json['nameEn'] ?? json['name'] ?? '',
    'nameAr': json['nameAr'] ?? json['name'] ?? '',
  });
}

extension CourtX on Court {
  String labelFor(String languageCode) =>
      languageCode == 'ar' ? (nameAr ?? name) : (nameEn ?? name);
}
