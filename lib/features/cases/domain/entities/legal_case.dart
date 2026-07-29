import 'package:freezed_annotation/freezed_annotation.dart';

part 'legal_case.freezed.dart';

@freezed
abstract class LegalCase with _$LegalCase {
  const LegalCase._();
  const factory LegalCase({
    required String id,
    required String title,
    required String caseNumber,
    required String attorneyName,
    required String status,
    required String category,
    required int hearingsCount,
    required int documentsCount,
    required int daysOpen,
  }) = _LegalCase;
}
