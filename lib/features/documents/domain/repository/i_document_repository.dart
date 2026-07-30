import '../../../../core/network/api_result.dart';
import '../entities/document_item.dart';

/// Mirrors API_CONTRACT.md finding I (Documents) — read-only for M3. No
/// query parameters exist on `GET /documents`, so `getDocuments` fetches the
/// full tenant collection; per-case filtering is done client-side by
/// `caseId`. No `getDocumentById` — that endpoint doesn't exist server-side.
abstract class IDocumentRepository {
  ApiResult<List<DocumentItem>> getDocuments();
}
