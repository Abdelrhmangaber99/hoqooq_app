import 'package:freezed_annotation/freezed_annotation.dart';

part 'court.freezed.dart';
part 'court.g.dart';

/// Wire shape for the nested `defaultCourt` object on `GET/POST/PATCH
/// /cases` per API_CONTRACT.md §7-8. Nested-only for M2 — no standalone
/// courts feature/list screen this milestone. `location`/`contactInfo`
/// were renamed to `city`/`address` in the 2026-07-30 backend update.
@freezed
abstract class Court with _$Court {
  const factory Court({
    required String id,
    required String name,
    required String type,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? city,
    String? address,
  }) = _Court;

  factory Court.fromJson(Map<String, dynamic> json) => _$CourtFromJson(json);
}
