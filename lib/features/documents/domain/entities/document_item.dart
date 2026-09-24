import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../cases/domain/entities/case_summary.dart';

part 'document_item.freezed.dart';
part 'document_item.g.dart';

/// Wire shape for `GET /documents` per API_CONTRACT.md finding I.
///
/// Named `DocumentItem`, not `Document`, to avoid clashing with `dart:io`'s
/// `File`-adjacent naming and any future ambiguity. `DocumentsController`
/// never applies `plainToInstance` on its `findAll` route (only the upload
/// response does) — the list response is the raw entity as loaded by
/// `DocumentsService.findAll`'s `relations: ['case']`, so `case` is nested
/// here but `uploadedBy`/`category` stay ID-only (neither relation is
/// requested).
///
/// No `GET /documents/{id}` endpoint exists at all — a document's detail
/// view is sourced from this list response, not a dedicated fetch. `GET
/// /documents/{id}/download` is a stub that doesn't return real file bytes
/// or a presigned URL (`{message: 'File download simulated', url}`) — this
/// model intentionally has no download-URL field since there's nothing
/// real to represent yet.
@freezed
abstract class DocumentItem with _$DocumentItem {
  const factory DocumentItem({
    required String id,
    required String title,
    String? description,
    required String fileType,
    required int sizeBytes,
    String? caseId,
    @JsonKey(name: 'case') CaseSummary? caseSummary,
    String? folderId,
    String? categoryId,
    String? linkedEntityType,
    String? linkedEntityId,
    required String uploadedById,
    required int versionNumber,
    String? sha256,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _DocumentItem;

  factory DocumentItem.fromJson(Map<String, dynamic> json) =>
      _$DocumentItemFromJson(json);
}
