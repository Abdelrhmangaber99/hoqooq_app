/// Architecture-review finding #10 (upload half): the real backend's
/// `FileInterceptor('file')` (`Hoqooq-main /src/modules/documents/
/// controllers/documents.controller.ts`) has no `limits`/`fileFilter`
/// configured — there is no documented server-side cap on size or type.
/// This is a client-side-only guardrail against picking something the
/// upload flow was never meant to handle (a multi-GB video, an
/// executable), not a business rule — the backend remains the actual
/// authority on what it accepts.
const int kMaxUploadSizeBytes = 20 * 1024 * 1024;

const List<String> kAllowedUploadExtensions = [
  'pdf',
  'doc',
  'docx',
  'jpg',
  'jpeg',
  'png',
  'heic',
];

enum UploadValidationError { unsupportedType, tooLarge }

/// Returns `null` when [filePath]/[sizeBytes] pass, otherwise which check
/// failed. Extension is checked before size — an unsupported type is a
/// clearer signal to show the user than a size limit that may not even
/// apply to that kind of file.
UploadValidationError? validateUploadFile(String filePath, int sizeBytes) {
  final dotIndex = filePath.lastIndexOf('.');
  final extension = dotIndex == -1
      ? ''
      : filePath.substring(dotIndex + 1).toLowerCase();
  if (!kAllowedUploadExtensions.contains(extension)) {
    return UploadValidationError.unsupportedType;
  }
  if (sizeBytes > kMaxUploadSizeBytes) {
    return UploadValidationError.tooLarge;
  }
  return null;
}
