import '../../../../core/network/api_result.dart';
import '../entities/document_item.dart';
import '../entities/downloaded_document.dart';

/// Current v2 private-document contract. Lists may be scoped by Case and
/// uploads require a Case and active global Document Category. Activity link
/// fields are supplied together when evidence belongs to another Case activity.
abstract class IDocumentRepository {
  ApiResult<List<DocumentItem>> getDocuments([String? caseId]);

  ApiResult<DocumentItem> uploadDocument({
    required String filePath,
    required String caseId,
    required String categoryId,
    String? description,
    String? linkedEntityType,
    String? linkedEntityId,
    void Function(int sent, int total)? onSendProgress,
  });

  ApiResult<DocumentItem> uploadVersion({
    required String documentId,
    required String filePath,
    String? changeSummary,
    void Function(int sent, int total)? onSendProgress,
  });

  ApiResult<DownloadedDocument> downloadDocument(
    String id,
    String fallbackFileName,
  );

  ApiResult<void> archiveDocument(String id);
}
