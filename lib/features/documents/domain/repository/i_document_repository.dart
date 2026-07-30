import '../../../../core/network/api_result.dart';
import '../entities/document_item.dart';

/// Mirrors API_CONTRACT.md finding I (Documents) — read plus upload-only
/// for M4. No query parameters exist on `GET /documents`, so `getDocuments`
/// fetches the full tenant collection; per-case filtering is done
/// client-side by `caseId`. No `getDocumentById` — that endpoint doesn't
/// exist server-side.
///
/// `uploadDocument` mirrors `POST /documents/upload` exactly: `file`
/// (multipart, required) and `caseId` (optional) are the only fields the
/// real backend controller accepts — there is no `description`/`category`/
/// `folderId` field on the request despite the response DTO having (always
/// null) placeholders for them, since `DocumentsService.create()` never
/// populates those columns. No update/delete/download — none of those are
/// real, working endpoints (delete doesn't exist at all; download is a
/// stub that returns a fake local path, not real file bytes).
abstract class IDocumentRepository {
  ApiResult<List<DocumentItem>> getDocuments();

  ApiResult<DocumentItem> uploadDocument({
    required String filePath,
    String? caseId,
    void Function(int sent, int total)? onSendProgress,
  });
}
